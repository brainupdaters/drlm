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

# download script
curl -O https://raw.githubusercontent.com/brainupdaters/drlm/develop/utils/drlm-build-install.sh

# execute script
bash drlm-build-install.sh

# pop directory
popd

# remove temporary folder
rm -rf $tmp_dir

# exit
exit
