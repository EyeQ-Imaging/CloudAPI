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
NEEDS_UPLOAD=true

#test if INPUT_FILE exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Input file doesn't exist, so assuming this is a valid fileKey"
    NEEDS_UPLOAD=false
fi

# Check for the optional third argument
if [ "$#" -ge 3 ]; then
    CORRECTION_PARAMETERS=$3
else
    CORRECTION_PARAMETERS=""
fi

echo "Input file path: $INPUT_FILE"
echo "Output file path: $OUTPUT_FILE"
echo "Correction parameters: $CORRECTION_PARAMETERS"

APIENDPOINT='https://api.perfectlyclear.io/v2'

function downloadFile {
    local url=$1
    local filePath=$2
    curl -L -s -o "$filePath" "$url"
    echo "Image saved to $filePath"
}

function getPreSignedURL {
    local output=$(curl -s -H "X-API-KEY: $APIKEY" "$APIENDPOINT/upload")
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
    local result=$(curl -s -H "X-API-KEY: $APIKEY" "$APIENDPOINT/pfc?&fileKey=$fileKey&$CORRECTION_PARAMETERS")
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
if [ "$NEEDS_UPLOAD" = true ]; then
    IFS=$'\n' read -d '' -r -a pre_signed_info < <(getPreSignedURL && printf '\0')
    fileKey=${pre_signed_info[1]}
    uploadUrl=${pre_signed_info[2]}

    uploadFile "$INPUT_FILE" "$uploadUrl"
else
    echo "skipping upload"
    fileKey=$INPUT_FILE
fi

echo "Starting correction process for $fileKey"
status_endpoint=$(startCorrection "$fileKey")
echo "Status endpoint: $status_endpoint"
statusUpdate "$status_endpoint"

downloadFile "$status_endpoint" "$OUTPUT_FILE"