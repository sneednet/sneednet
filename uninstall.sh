#!/bin/bash

read -p "All your Freenet data will be deleted. Continue? " -n 1 -r
echo ""    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi


rm OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11*
rm new_installer_offline_1498*
rm -rf jdk-21.0.5+11*
rm -rf "Freenet-install"

