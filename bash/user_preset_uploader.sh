#!/bin/bash


show_help() {
	echo "Usage: ./user_preset_uploader.sh [options]"
	echo ""
	echo "Options:"
	echo "  -h, --help   						Show this help message and exit"
	echo "  -k, --apikey      			user API-KEY"
	echo "  -n, --name							preset name"
	echo "  -d, --description       preset description"
	echo "  -p, --path              path to preset"
}


while getopts "hk:p:n:d:" opt; do
	case $opt in
		h)
			show_help
			exit 0
			;;
		
		k)
			KEY="$OPTARG"
			;;
		p)
			path_to_preset="$OPTARG"
			;;
		n)
			name="$OPTARG"
			;;
		d)
			description="$OPTARG"
			;;
		*)
			echo "Unknown option: $OPTARG" >&2
			show_help
			exit 1
			;;
	esac
done

echo "API-KEY $KEY"
echo "path to preset $path_to_preset"
echo "preset name $name"
echo "preset description $description"

DOMAIN="https://api.perfectlyclear.io"

request_body="{
  \"name\": \"$name\",
  \"description\": \"$description\"
}"
echo "request body: $request_body"
upload_json=$(curl -X POST "$DOMAIN/v2/presets/" -H "X-API-KEY: $KEY" -H "Content-Type: application/json" -d "{
  \"name\": \"$name\",
  \"description\": \"$description\"
}")
echo "upload json: $upload_json"

echo "upload_json" $upload_json
if echo "$upload_json" | jq -e 'has("error")' > /dev/null; then
  echo $upload_json | jq -r '.error'
  echo "error"
  exit 1
fi
#parse upload URL json
uploadUrl=$(echo $upload_json | jq -r '.uploadUrl')
presetId=$(echo $upload_json | jq -r '.presetId')
echo "=========================================="
echo "upload URL" $uploadUrl
echo "presetId" $presetId
echo "+++++++++++++++++++"
curl -X PUT "$uploadUrl" --upload-file $path_to_preset -H "X-API-KEY: $KEY" 
echo "+++++++++++++++++++"  
echo $Put_result