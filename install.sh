#!/bin/bash

version="11.0.24_8"
filename="OpenJDK11U-jdk_arm_linux_hotspot_${version}.tar.gz"
known_hash="893ab22f39f102724e7b77b7a06e09b33ee0551b166c0154ce19d4e6abd7e346d0a8314fe2e675e102febf93e001679a1c7c665f6b131c04a453cfbfbabb5003"

echo "Downloading AdoptOpenJDK"
wget "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.24%2B8/${filename}"

echo "Checking hash for file ${filename}"
sha=$( shasum -a 512 "$filename" | awk '{ print $1 }')

if [[ $sha == $known_hash ]]
then
  echo "Hash matches"
else
  echo $sha "Hash doesn't match, quitting"
  exit
fi

echo "Exctracting"
tar -xzvf $filename

#Download Freenet
echo "Downloading Freenet jar"
wget "https://www.draketo.de/dateien/freenet/build01498/new_installer_offline_1498.jar"
