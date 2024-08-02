#!/bin/bash


show_help() {
	echo "Usage: ./user_preset_list.sh [options]"
	echo ""
	echo "Options:"
	echo "  -h, --help   			Show this help message and exit"
	echo "  -k, --apikey      		user API-KEY"
}


while getopts "hk:" opt; do
	case $opt in
		h)
			show_help
			exit 0
			;;
		
		k)
			KEY="$2"
			shift 2
			;;

		*)
			echo "Unknown option: $1"
			show_help
			exit 1
			;;
	esac
done

echo "API-KEY $KEY"

DOMAIN="https://api.perfectlyclear.io"


get_presets_list_URL=$DOMAIN/v2/presets?limit=30

presets_list=$(curl -s -H "accept: application/json" -H "X-API-KEY: ${KEY}" -X GET "{$get_presets_list_URL}")
echo $presets_list
names=$(echo ${presets_list} | jq -r '.presets[].name')
echo "presets names: $names"
echo "presetsIds:"
ids=$(echo ${presets_list} | jq -r '.presets[].presetId')
echo $ids