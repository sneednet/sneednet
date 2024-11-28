#!/bin/bash

calculate_sha256() {
    shasum -a 256 "$1" | awk '{print $1}'
}

check_and_redownload_file() {
    echo "check_and_redownload_file called"
    local FILE_PATH=$1
    local EXPECTED_SIZE=$2
    local EXPECTED_HASH=$3
    local DOWNLOAD_URL=$4
    
    # Check if file exists
    echo "Checking if file $FILE_PATH exists."
    if [ ! -f "$FILE_PATH" ]; then
        echo "File does not exist at path: $FILE_PATH, downloading."
        wget --output-document="$FILE_PATH" "$DOWNLOAD_URL"
    else
        echo "File exists, checking size and hash."
    fi
    
    # Get actual details of the file
    ACTUAL_SIZE=$(stat -c%s "$FILE_PATH")
    ACTUAL_HASH=$(calculate_sha256 "$FILE_PATH")

    echo "ACTUAL_SIZE: $ACTUAL_SIZE"
    echo "EXPECTED_SIZE: $EXPECTED_SIZE"
    echo "ACTUAL_HASH: $ACTUAL_HASH"
    echo "EXPECTED_HASH: $EXPECTED_HASH"

    # Compare sizes and hashes
    if [[ "$ACTUAL_SIZE" == "$EXPECTED_SIZE" && "$ACTUAL_HASH" == "$EXPECTED_HASH" ]]; then
        echo "File $FILE_PATH has correct size and hash. Continuing."
        return 0
    else
        echo "File $FILE_PATH has incorrect size or hash."
        # If files do not match, rename and redownload
        TIMESTAMP=$(date +%s)
        NEW_FILENAME="${FILE_PATH}_corrupt_${TIMESTAMP}"
        mv "$FILE_PATH" "$NEW_FILENAME"
        
        echo "Downloading from URL: $DOWNLOAD_URL"
        wget --output-document="$FILE_PATH" "$DOWNLOAD_URL"
        
        # Recalculate hash and size after downloading
        ACTUAL_SIZE=$(stat -c%s "$FILE_PATH")
        ACTUAL_HASH=$(calculate_sha256 "$FILE_PATH")
        
        echo "ACTUAL_SIZE: $ACTUAL_SIZE"
        echo "EXPECTED_SIZE: $EXPECTED_SIZE"
        echo "ACTUAL_HASH: $ACTUAL_HASH"
        echo "EXPECTED_HASH: $EXPECTED_HASH"
        
        # Verify newly downloaded file
        if [[ "$ACTUAL_SIZE" == "$EXPECTED_SIZE" && "$ACTUAL_HASH" == "$EXPECTED_HASH" ]]; then
            echo "File $FILE_PATH has correct size and hash. Continuing."
            return 0
        else
            echo "Error: file $FILE_PATH has incorrect size or hash, exiting."
            exit 1
        fi
    fi
}

echo "Downloading curl."
wget -O .path/curl "https://github.com/moparisthebest/static-curl/releases/download/v7.67.0/curl-amd64"
PATH="$PATH:./path"
curl --version

echo "Downloading JDK."
jdk_version="21.0.5_11"
jdk_filename="OpenJDK21U-jdk_x64_linux_hotspot_$jdk_version.tar.gz"
jdk_known_hash="3c654d98404c073b8a7e66bffb27f4ae3e7ede47d13284c132d40a83144bfd8c"
jdk_folder="jdk-${jdk_version/_/+}"
jdk_url="https://github.com/adoptium/temurin21-binaries/releases/download/$jdk_folder/$jdk_filename"
jdk_size="206798126"
check_and_redownload_file $jdk_filename $jdk_size $jdk_known_hash $jdk_url

echo "Checking if JDK folder exists."
jdk_folder="jdk-21.0.5+11"
if [ -d "$jdk_folder" ]; then
    echo "A previous folder for the JDK has been detected, skipping JDK extraction (folder $jdk_folder)."
else
    echo "Extracting JDK."
    tar -xzvf "$jdk_filename"
fi

echo "Downloading Freenet jar"
freenet_version="1498"
freenet_filename="new_installer_offline_$freenet_version.jar"
freenet_known_hash="25522e5723622a20c5359b5eaab3faa9aa338afb5125c754babfd55a49853385"
freenet_url="https://www.draketo.de/dateien/freenet/build0$freenet_version/$freenet_filename"
freenet_size="20540807"
check_and_redownload_file $freenet_filename $freenet_size $freenet_known_hash $freenet_url

echo "Installing Freenet."
export PATH="$PATH:$(realpath "$jdk_folder/bin")"
freenet_folder="Freenet-install"
if [ -d "$freenet_folder" ]; then
    echo "A previous Freenet installation folder has been detected, skipping installation (folder $freenet_folder)."
    echo "Starting Freenet".
    $freenet_folder/run.sh start
else
    echo "Installing Freenet to local folder."
    $jdk_folder/bin/java -jar new_installer_offline_$freenet_version.jar -options installer_properties.xml
fi

echo "Waiting 20s for Freenet to be initialized."
sleep 20

echo "Extract the initialization wizard form password."
wget -O wizard_form.html http://127.0.0.1:8888/wiz/
form_password=$(grep -oP 'name="formPassword"\s*type="hidden"\s*value="\K[^"]+' wizard_form.html | head -1)
rm wizard_form.html

echo "form_password: $form_password"
sleep 5

echo "Setting unlimited bandwidth limit."
wget -O - --post-data="formPassword=$form_password&monthlyLimit=999999999&downLimit=976562&upLimit=976562&storage=5&password=&confirmPassword=" "http://127.0.0.1:8888/wiz/" > /dev/null

echo "Waiting 20s for settings to be applied."
sleep 20

curl 'http://127.0.0.1:8888/CHK@NvT50rE2pz9bne9O-OE~GFY8z-JKul8NoxUDHWv7Evc,yQNgly4kq6WX4pT8A821R4fuOnZUroxi~8vtM1JAehg,AAMC--8/fms-linux-x86-bin-0.3.85.tar.gz' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:123.0) Gecko/20100101 Firefox/123.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-User: ?1' > download_form.html && form_password=$(grep -oP 'name="formPassword"\s*type="hidden"\s*value="\K[^"]+' download_form.html | head -1) && echo "form_password: $form_password" && curl --user-agent 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:131.0) Gecko/20100101 Firefox/131.0' -X POST 'http://127.0.0.1:8888/downloads/' -H 'Content-Type: multipart/form-data' -F "formPassword=$form_password" -F "key=CHK@NvT50rE2pz9bne9O-OE~GFY8z-JKul8NoxUDHWv7Evc,yQNgly4kq6WX4pT8A821R4fuOnZUroxi~8vtM1JAehg,AAMC--8/fms-linux-x86-bin-0.3.85.tar.gz" -F "return-type=direct" -F "persistence=forever" -F "download=Fetch" -F "filterData=filterData"

echo "Waiting 20s for FMS download request to be registered." 
sleep 20

curl http://127.0.0.1:8888/downloads/ > download_form.html && form_password=$(grep -oP 'name="formPassword"\s*type="hidden"\s*value="\K[^"]+' download_form.html | head -1) && echo "form_password: $form_password" && curl -X POST http://127.0.0.1:8888/downloads/ -H 'Content-Type: multipart/form-data' -F "formPassword=$form_password" -F 'restart_request=Restart' -F 'disableFilterData=disableFilterData' -F 'identifier-0= FProxy:fms-linux-x86-bin-0.3.85.tar.gz' -F 'key-0=freenet:CHK@NvT50rE2pz9bne9O-OE~GFY8z-JKul8NoxUDHWv7Evc,yQNgly4kq6WX4pT8A821R4fuOnZUroxi~8vtM1JAehg,AAMC--8/fms-linux-x86-bin-0.3.85.tar.gz' -F 'filename-0=fms-linux-x86-bin-0.3.85.tar.gz'

echo ""
echo "Waiting 15s for web interface FMS download to start."
sleep 15

echo "Downloading FMS. This could take a few minutes. Please be patient."
./download_FMS.sh
echo "Exctracting FMS."
mv /tmp/fms-linux-x86-bin-0.3.85.tar.gz .

./install_fms.sh

read -p "Press the Enter key to continue."

