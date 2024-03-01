#!/bin/bash

set -a
source .env
set +a

# Check if the APIKEY is empty
if [ -z "$APIKEY" ]; then
    echo "Error: The APIKEY is not set or it's empty in the .env file."
    exit 1
fi

# Check if at least two arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 INPUT_FILE OUTPUT_FILE [CORRECTION_PARAMETERS]"
    exit 1
fi

# Assign the first argument to INPUT_FILE and the second to OUTPUT_FILE
INPUT_FILE=$1
OUTPUT_FILE=$2

# Check for the optional third argument
if [ "$#" -ge 3 ]; then
    CORRECTION_PARAMETERS=$3
else
    CORRECTION_PARAMETERS=""
fi

echo "Input file path: $INPUT_FILE"
echo "Output file path: $OUTPUT_FILE"
echo "Correction parameters: $CORRECTION_PARAMETERS"

DOMAIN='https://api.perfectlyclear.io'
FILE_TYPE='image'

function downloadFile {
    local url=$1
    local filePath=$2
    curl -L -s -o "$filePath" "$url"
    echo "Image saved to $filePath"
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
    local result=$(curl -s -H "X-API-KEY: $APIKEY" "$DOMAIN/v2/pfc?fileType=$FILE_TYPE&fileKey=$fileKey&$CORRECTION_PARAMETERS")
    local statusEndpoint=$(echo $result | jq -r '.statusEndpoint')
    echo $statusEndpoint
}

function statusUpdate {
    local statusEndpoint=$1
    local status=''
    while : ; do
        local result=$(curl -s "$statusEndpoint?noRedirect=true")
        status=$(echo $result | jq -r '.status')
        echo "Current correction status is: $status"

        if [[ "$status" == "COMPLETED" ]]; then
            break
        elif [[ "$status" == "REJECTED" || "$status" == "FAILED" ]]; then
            local statusText=$(echo $result | jq -r '.statusText')
            echo "Process $status with reason: $statusText"
            exit 1
        fi

        sleep 1
    done
}

# Main execution flow
IFS=$'\n' read -d '' -r -a pre_signed_info < <(getPreSignedURL && printf '\0')
fileKey=${pre_signed_info[1]}
uploadUrl=${pre_signed_info[2]}

uploadFile "$INPUT_FILE" "$uploadUrl"

status_endpoint=$(startCorrection "$fileKey")
echo $status_endpoint
statusUpdate "$status_endpoint"

downloadFile "$status_endpoint" "$OUTPUT_FILE"