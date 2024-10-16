#!/bin/bash

# "DRLM build & install script"
INSTALLER_VERSION="202409.04"
GOLANG_VERSION="1.21.5"
# "Author: Pau Roura - Brain Updaters"
# "Website: https://drlm.org"
# "GitHub: https://github.com/brainupdaters/drlm"


# Set default Repository and Branch
DRLM_GIT_BASE_URL="${DRLM_GIT_BASE_URL:-https://github.com/}"
DRLM_GIT_REPOSITORY="${DRLM_GIT_REPOSITORY:-brainupdaters/drlm}"
DRLM_GIT_BRANCH="${DRLM_GIT_BRANCH:-develop}"


# Show information about the script
echo "DRLM build & installation script"
echo "Version: $INSTALLER_VERSION"
echo "Website: https://drlm.org"
echo "Git: ${DRLM_GIT_BASE_URL}${DRLM_GIT_REPOSITORY} -- Branch: ${DRLM_GIT_BRANCH}"
echo ""


# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo"
    echo ""
    exit
fi


# Check what Linux distribution is being used
if [ -f /etc/dpkg/origins/ubuntu ]; then 
    linux_distro="Ubuntu"
elif [ -f /etc/debian_version ] && [ ! -f /etc/dpkg/origins/ubuntu ]; then 
    linux_distro="Debian"
elif [ -f /etc/redhat-release ] && [ ! -f /etc/centos-release ] && [ ! -f /etc/rocky-release ]; then 
    linux_distro="RedHat"
elif [ -f /etc/rocky-release ] && [ -f /etc/redhat-release ]; then  
    linux_distro="Rocky"
elif [ -f /etc/centos-release ] && [ -f /etc/redhat-release ]; then  
    linux_distro="CentOS"
elif [ -f /etc/SuSE-release ] || [ -f /etc/SUSE-brand ]; then 
    linux_distro="Suse"
else 
    linux_distro="Unknown"
fi


# Check what Linux distribution version is being used
case "$linux_distro" in
    Ubuntu)
        linux_distro_version=$(grep "^VERSION_ID=" /etc/os-release | cut -d\" -f2)
        ;;
    Debian)
        linux_distro_version=$(cat /etc/debian_version)
        ;;
    RedHat)
        linux_distro_version=$(cat /etc/redhat-release | awk -F"release" '{print $2}' | awk '{print $1}')
        ;;
    Rocky)
        linux_distro_version=$(cat /etc/rocky-release | awk -F"release" '{print $2}' | awk '{print $1}')
        ;;
    CentOS)
        linux_distro_version=$(cat /etc/centos-release | awk -F"release" '{print $2}' | awk '{print $1}')
        ;;
    Suse)
        if [ -f /etc/SuSE-release ]; then
            linux_distro_version=$(grep VERSION /etc/SuSE-release | awk '{print $3}')
        elif [ -f /etc/SUSE-brand ]; then
            linux_distro_version=$(grep VERSION /etc/SUSE-brand | awk '{print $3}')
        fi
        ;;
    *)
        linux_distro_version="Unknown"
        ;;
esac


# Check if the linux_distro variable is empty or Unknown
if [ -z "$linux_distro" ] || [ "$linux_distro" = "Unknown" ]; then
    echo "Unknown Linux distribution $linux_distro - $linux_distro_version"
    echo "Supported Linux distributions: Debian, Ubuntu, CentOS, RedHat, Rocky, Suse"
    exit
fi


# Check hostname is not localhost
if [ "$(hostname)" = "localhost" ]; then
    echo "Please change the hostname of your server before installing DRLM"
    echo "Hostname is currently set to localhost"
    exit
fi


# Function to check if go is installed
check_go() {
    if [ -x "$(command -v go)" ]; then
        echo "Go is already installed"
    else
        echo "Go is not installed"
        echo "Installing Go"
        install_golang
    fi
}


# Function to install golang
install_golang() {
    # Download Go binary
    GOLANG_URL="https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz"
    echo "Downloading $GOLANG_URL"
    curl -OL $GOLANG_URL
    # Remove any existing Go installation and extract the downloaded Go binary
    rm -rf /usr/local/go && tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz
    # Add Go binary to PATH
    export PATH=$PATH:/usr/local/go/bin
    # Add to bashrc
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
    # Set Go environment variable
    go env -w GO111MODULE="auto"
    # Remove the downloaded Go binary
    rm -rf go${GOLANG_VERSION}.linux-amd64.tar.gz
}

# Function to get DRLM version
get_drlm_version() {
    DRLM_VERSION="$(curl https://raw.githubusercontent.com/${DRLM_GIT_REPOSITORY}/${DRLM_GIT_BRANCH}/usr/sbin/drlm | grep "readonly VERSION=" | awk -F= '{print $2}')"
}

# Function to clone DRLM repository
drlm_clon_repo() {
    # Get DRLM version
    get_drlm_version
    # DRLM URL
    DRLM_CLONE_URL="${DRLM_GIT_BASE_URL}${DRLM_GIT_REPOSITORY}"
    echo "Clonning $DRLM_CLONE_URL"
    # Clone the DRLM project
    git clone $DRLM_CLONE_URL
    # Navigate into the project directory
    cd drlm
    # Checkout Branch/Commit
    git checkout $DRLM_GIT_BRANCH
}

# Function to add DRLM internal client
add_drlm_internal_client() {
    # check if drlm.sqlite exists
    if [ ! -f "/var/lib/drlm/drlm.sqlite" ]; then return; fi

    # Checkl if client internal exists
    num_internals=$(echo "SELECT count(*) FROM clients WHERE idclient = 0;" | sqlite3 /var/lib/drlm/drlm.sqlite)
    if [ $num_internals -eq 0 ]; then
        # add and install drlm internal client
        drlm -vD addclient --internal -I 
    fi
    
    # add drlm internal client jobs and disable
    num_jobs=$(echo "SELECT count(*) FROM jobs WHERE clients_id = 0;" | sqlite3 /var/lib/drlm/drlm.sqlite)
    if [ $num_jobs -eq 0 ]; then
        drlm addjob -c internal -s $(date -d "tomorrow" +'%Y-%m-%dT08:00') -r 1day
        drlm addjob -c internal -C iso -s $(date -d "next friday" +'%Y-%m-%dT12:00') -r 1month
        
        for job in $(echo "SELECT idjob FROM jobs WHERE clients_id = 0;" | sqlite3 -init <(echo .timeout 2000) /var/lib/drlm/drlm.sqlite); do drlm sched -d -I $job; done
    fi
}

echo "Installing DRLM on $linux_distro $linux_distro_version"
case "$linux_distro" in


    # Check if the linux_distro is "Debian" or "Ubuntu"
    Debian | Ubuntu )
        # Update the system packages
        apt update
        # Install necessary packages
        apt -y install git build-essential debhelper curl bash-completion
         # Check Go Installation
        check_go
        # Clone the DRLM project
        drlm_clon_repo
        # Build the Debian package
        make deb
        # Navigate back to the parent directory
        cd ..
        # Install the built Debian package
        apt -y install ./drlm_${DRLM_VERSION}_all.deb    
        ;;
    

    # Check if the linux_distro is "CentOS", "RedHat" or "Rocky"
    CentOS | RedHat | Rocky )
        # if selinux is enabled show warning
        if [ "$(getenforce)" = "Enforcing" ]; then
            echo "SELinux is enabled. It is recommended to disable SELinux before installing DRLM."
            echo "Do you want to continue? (y/n)"
            read -r response
            if [ "$response" = "y" ]; then

                # Set to disable selinux
                sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config    

                # Disable SELinux
                setenforce 0
            else
                # Continue with the installation without disabling SELinux
                echo "Continuing with the installation without disabling SELinux"
                echo "Please make sure that SELinux is configured properly"
            fi
        fi

        # if firewalld is enabled show warning
        if [ "$(systemctl is-active firewalld)" = "active" ]; then
            echo "Firewalld is enabled. It is recommended to disable Firewalld before installing DRLM."
            echo "Do you want to continue? (y/n)"
            read -r response
            if [ "$response" = "y" ]; then

                # Disable firewalld
                systemctl disable firewalld
                systemctl stop firewalld
            else
                # Continue with the installation without disabling firewalld
                echo "Continuing with the installation without disabling firewalld"
                echo "Please make sure that firewalld is configured properly"
            fi
        fi
        
        # Install necessary packages
        yum install -y git rpm-build make bash-completion gcc
         # Check Go Installation
        check_go
        # Clone the DRLM project
        drlm_clon_repo
        # Build the RPM package
        make rpm
        # Install the built RPM package
        yum install -y ./drlm-${DRLM_VERSION}-*.rpm
        ;;


    # Check if the linux_distro is "Suse"
    Suse )
        # if firewalld is enabled show warning
        if [ "$(systemctl is-active firewalld)" = "active" ]; then
            echo "Firewalld is enabled. It is recommended to disable Firewalld before installing DRLM."
            echo "Do you want to continue? (y/n)"
            read -r response
            if [ "$response" = "y" ]; then

                # Disable firewalld
                systemctl disable firewalld
                systemctl stop firewalld
            else
                # Continue with the installation without disabling firewalld
                echo "Continuing with the installation without disabling firewalld"
                echo "Please make sure that firewalld is configured properly"
            fi
        fi

        # Install necessary packages
        zypper install -y git-core rpm-build bash-completion curl
        # Check Go Installation
        check_go
        # Clone the DRLM project
        drlm_clon_repo
        # Build the RPM package
        make rpm
        # Install the built RPM package
        zypper install -y --allow-unsigned-rpm ./drlm-${DRLM_VERSION}-*.rpm
        ;;
    

    # Check if the linux_distro is "Unknown"
    *)
        echo "Unknown Linux distribution $linux_distro - $linux_distro_version"
        echo "Supported Linux distributions: Debian, Ubuntu, CentOS, RedHat, Rocky, Suse"
        exit
        ;;
esac


# Check if the DRLM installation was successful
if [ -f /usr/sbin/drlm ]; then
    echo "Adding DRLM internal client"
    add_drlm_internal_client

    echo "DRLM installed successfully"
    echo "You can now start using DRLM"
    echo "Please visit https://drlm.org for more information"
else
    echo "DRLM installation failed"
    echo "Please visit https://drlm.org for more information"
fi
