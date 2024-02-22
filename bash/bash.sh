#!/bin/bash

# this is a quick script to demonstrate how to use the Perfectly Clear Web API
# it will upload the file you specify and will process it, then download the results
# to a subdirectory called "output"
#
# You can set correction parameters after the filename, for example:
# ./perfectly_clear_webapi.sh ../myimage.jpg "preset=my_favorite_settings&outputQuality=100"
#
# see the API documentation for more details on the parameters you can use
# https://perfectlyclear.io/docs/#/Upload%20and%20Correct/get_pfc

# enter your API KEY, found here: https://perfectlyclear.io/webapi
KEY=
UPURL=https://api.perfectlyclear.io/v2/upload
CORRECT_URL=https://api.perfectlyclear.io/v2/pfc?fileKey=

if [ ! -f "$1" ]; then
    echo cannot find file: $1
    echo usage "$0 <filename> [queryparams]"
    exit 1
fi

if [ "$KEY" == "" ]; then
    echo missing API KEY
    echo edit this scirpt and try again
    exit 1
fi

QUERYPARAMS=""

if [ ! -z $2 ]; then
    echo Adding Query param: ${2}
    QUERYPARAMS=${2}
fi

FILENAME=`basename $1`

# if the output directory doesn't exist, create it
if [ ! -d "output" ]; then
    mkdir output
fi

echo `date +%H:%M:%S` START: request presigned URL
ANSWER=$(curl -s -H "accept: application/json" -H "X-API-KEY: ${KEY}" -X GET "${UPURL}")

upload_url=$(echo ${ANSWER} | jq -r '.upload_url')
imageKey=$(echo ${ANSWER} | jq -r '.fileKey')
#echo full response:
#echo ${ANSWER}

echo "  IMAGE KEY: $imageKey"
#echo "  upload_url: $upload_url"
echo "  uploading: $FILENAME"
echo -----
echo `date +%H:%M:%S` starting upload

curl -s -H "X-API-KEY: ${KEY}" -X PUT "${upload_url}" --upload-file "${1}"
echo `date +%H:%M:%S` upload completed


echo starting  "${CORRECT_URL}${imageKey}&${QUERYPARAMS}"
ANSWER=$(curl -s -H "X-API-KEY: ${KEY}" -X GET "${CORRECT_URL}${imageKey}&fileType=image&${QUERYPARAMS}")

STATUSURL=$(echo ${ANSWER} | jq -r '.statusEndpoint')

echo `date +%H:%M:%S` STATUS URL: $STATUSURL

while true; do
    # Call the API endpoint using curl and store the response in a variable
    response=$(curl -s -w "%{http_code}" -H "X-API-KEY: ${KEY}" -X GET "${STATUSURL}")

    # Extract the HTTP status code and JSON body
    http_code=${response: -3}
    json_body=${response:0:${#response}-3}

    # Check if the HTTP status code is 302 (Found)
    if [ "$http_code" -eq 302 ]; then
        # Follow the redirect using curl -L and download the file
        echo `date +%H:%M:%S` "Received $status_code status code. Downloading"
        #curl -s -H "X-API-KEY: ${KEY}" -X GET "${STATUSURL}"
        curl -s -L -H "X-API-KEY: ${KEY}" -X GET "${STATUSURL}" -o "output/${FILENAME}"
        echo `date +%H:%M:%S`  PROCESSING COMPLETED.  Saved to output/${FILENAME}
        break
    elif [ "$http_code" -eq 200 ]; then
        # Check if the JSON body for status
        if [[ "$json_body" == *'"status":"PENDING"'* || "$json_body" == *'"status":"PROCESSING"'* ]]; then
            echo "Status is PENDING or PROCESSING. Retrying in 1 second..."
            sleep 1
        else
            echo "Status is unknown: $json_body"
            break
        fi
    else
        echo "HTTP request failed with status code: $http_code"
        break
    fi
done