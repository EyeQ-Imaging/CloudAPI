#!/bin/bash

DOMAIN='https://api.perfectlyclear.io'
APIKEY=''

INPUT_URL='https://eyeq.photos/wp-content/uploads/2022/07/pfc-home-perfect-landscapes-before-min.jpg'
INPUT_FILE='./input-image.jpg'
OUTPUT_FILE='./output-image.jpg'

FILE_TYPE='image'
CORRECTION_PARAMETERS='&preset=Universal'

function downloadFile {
    local url=$1
    local filePath=$2
    curl -L -s -o "$filePath" "$url"
    echo "Image from $url saved to $filePath"
}

function getPreSignedURL {
    local output=$(curl -s -H "X-API-KEY: $APIKEY" "$DOMAIN/v2/upload")
    local fileKey=$(echo $output | jq -r '.fileKey')
    local uploadUrl=$(echo $output | jq -r '.upload_url')
    echo "Pre-signed URL received from Perfectly Clear API"
    echo "$fileKey"
    echo "$uploadUrl"
}

function uploadFile {
    local inputFile=$1
    local uploadUrl=$2
    curl -s --upload-file "$inputFile" "$uploadUrl"
    echo "Image from $inputFile uploaded to Perfectly Clear storage"
}

function startCorrection {
    local fileKey=$1
    local result=$(curl -s -H "X-API-KEY: $APIKEY" "$DOMAIN/v2/pfc?fileType=$FILE_TYPE&fileKey=$fileKey$CORRECTION_PARAMETERS")
    local statusEndpoint=$(echo $result | jq -r '.statusEndpoint')
    echo $statusEndpoint
}

function statusUpdate {
    local statusEndpoint=$1
    local status=''
    while [ "$status" != "COMPLETED" ]; do
        local result=$(curl -s "$statusEndpoint?noRedirect=true")
        status=$(echo $result | jq -r '.status')
        echo "Current correction status is: $status"
        sleep 1
    done
}

# Main execution flow
IFS=$'\n' read -d '' -r -a pre_signed_info < <(getPreSignedURL && printf '\0')
fileKey=${pre_signed_info[1]}
uploadUrl=${pre_signed_info[2]}

downloadFile "$INPUT_URL" "$INPUT_FILE"
uploadFile "$INPUT_FILE" "$uploadUrl"

status_endpoint=$(startCorrection "$fileKey")
echo $status_endpoint
statusUpdate "$status_endpoint"

downloadFile "$status_endpoint" "$OUTPUT_FILE"
