#!/bin/bash


show_help() {
	echo "Usage: ./user_preset_download.sh [options]"
	echo ""
	echo "Options:"
	echo "  -h, --help   			Show this help message and exit"
	echo "  -k, --apikey      		user API-KEY"
	echo "  -p, --preset			presetId"
}


while getopts "hk:p:" opt; do
	case $opt in
		h)
			show_help
			exit 0
			;;
		
		k)
			KEY="$OPTARG"
			;;
		p)
			presetId="$OPTARG"
			;;
		*)
			echo "Unknown option: $OPTARG" >&2
			show_help
			exit 1
			;;
	esac
done

echo "API-KEY $KEY"
echo "presetId $presetId"

DOMAIN="https://api.perfectlyclear.io"


get_one_preset_URL=$DOMAIN/v2/presets/$presetId #?limit=30

preset_json=$(curl -s -H "accept: application/json" -H "X-API-KEY: ${KEY}" -X GET "{$get_one_preset_URL}")
uri=$(echo ${preset_json} | jq -r ".uri")
echo "uri: $uri"
curl -H "X-API-KEY: ${KEY}" -o "downloaded.preset" "$uri"
