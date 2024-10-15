#!/bin/bash 

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    echo ""
    exit
fi

# create temporary folder with a random name that starts with drlm
tmp_dir=$(mktemp -d -t drlm-XXXXXXXXXX)

# push directory
pushd $tmp_dir

# Set default Repository and Branch
DRLM_GIT_BUILD_INSTALL_URL="${DRLM_GIT_BUILD_INSTALL_URL:-https://raw.githubusercontent.com/brainupdaters/drlm/develop/utils/drlm-build-install.sh}"

# download script
curl -O $DRLM_GIT_BUILD_INSTALL_URL

# execute script
bash drlm-build-install.sh

# pop directory
popd

# remove temporary folder
rm -rf $tmp_dir

# exit
exit
