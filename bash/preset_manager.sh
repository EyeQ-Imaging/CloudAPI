#!/bin/bash

# Manages user presets on the Perfectly Clear API.
# Supports listing, viewing, downloading, uploading, and deleting presets.
#
# Usage: ./preset_manager.sh <command> [options]
# Run ./preset_manager.sh -h for full help.

set -a
source .env
set +a

DOMAIN="${APIENDPOINT:-https://api.perfectlyclear.io/v2}"

show_help() {
	echo "Usage: ./preset_manager.sh <command> [options]"
	echo ""
	echo "Commands:"
	echo "  list                                   List all presets"
	echo "  get      -p <presetId>                 Show metadata for one preset"
	echo "  download -p <presetId> [-o <file>]     Download a preset file"
	echo "  upload   -n <name> -d <desc> -f <file> Create and upload a preset"
	echo "  delete   -p <presetId>                 Delete a preset"
	echo ""
	echo "Global options (place after the command):"
	echo "  -k <apikey>   Override API key from .env"
	echo "  -h            Show this help message"
}

# Parses -k (API key override) from the argument list.
# Sets KEY and removes the -k flag so subcommand getopts doesn't see it.
parse_global_options() {
	local args=()
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-k)
				KEY="$2"
				shift 2
				;;
			*)
				args+=("$1")
				shift
				;;
		esac
	done
	REMAINING_ARGS=("${args[@]}")
}

# Use APIKEY from .env unless overridden by -k
resolve_api_key() {
	if [ -z "$KEY" ]; then
		KEY="$APIKEY"
	fi
	if [ -z "$KEY" ]; then
		echo "Error: No API key provided. Set APIKEY in .env or pass -k <key>."
		exit 1
	fi
}

cmd_list() {
	local response
	response=$(curl -s -H "accept: application/json" -H "X-API-KEY: ${KEY}" \
		-X GET "${DOMAIN}/presets?limit=30")

	if ! echo "$response" | jq -e '.presets' > /dev/null 2>&1; then
		echo "Error: $response"
		exit 1
	fi

	echo "$response" | jq -r '.presets[] | "\(.presetId)\t\(.name)"'
}

cmd_get() {
	local presetId=""
	OPTIND=1
	while getopts "p:" opt; do
		case $opt in
			p) presetId="$OPTARG" ;;
			*) echo "Usage: preset_manager.sh get -p <presetId>"; exit 1 ;;
		esac
	done

	if [ -z "$presetId" ]; then
		echo "Error: -p <presetId> is required."
		exit 1
	fi

	curl -s -H "accept: application/json" -H "X-API-KEY: ${KEY}" \
		-X GET "${DOMAIN}/presets/${presetId}" | jq .
}

cmd_download() {
	local presetId=""
	local output=""
	OPTIND=1
	while getopts "p:o:" opt; do
		case $opt in
			p) presetId="$OPTARG" ;;
			o) output="$OPTARG" ;;
			*) echo "Usage: preset_manager.sh download -p <presetId> [-o <file>]"; exit 1 ;;
		esac
	done

	if [ -z "$presetId" ]; then
		echo "Error: -p <presetId> is required."
		exit 1
	fi

	if [ -z "$output" ]; then
		output="${presetId}.preset"
	fi

	local preset_json
	preset_json=$(curl -s -H "accept: application/json" -H "X-API-KEY: ${KEY}" \
		-X GET "${DOMAIN}/presets/${presetId}")

	local uri
	uri=$(echo "$preset_json" | jq -r '.uri')
	if [ -z "$uri" ] || [ "$uri" = "null" ]; then
		echo "Error: Could not get download URI."
		echo "$preset_json" | jq .
		exit 1
	fi

	curl -s -H "X-API-KEY: ${KEY}" -o "$output" "$uri"
	echo "Downloaded preset to $output"
}

cmd_upload() {
	local name=""
	local description=""
	local filepath=""
	OPTIND=1
	while getopts "n:d:f:" opt; do
		case $opt in
			n) name="$OPTARG" ;;
			d) description="$OPTARG" ;;
			f) filepath="$OPTARG" ;;
			*) echo "Usage: preset_manager.sh upload -n <name> -d <desc> -f <file>"; exit 1 ;;
		esac
	done

	if [ -z "$name" ] || [ -z "$description" ] || [ -z "$filepath" ]; then
		echo "Error: -n <name>, -d <description>, and -f <file> are all required."
		exit 1
	fi

	if [ ! -f "$filepath" ]; then
		echo "Error: File not found: $filepath"
		exit 1
	fi

	# Create the preset and get an upload URL
	local create_response
	create_response=$(curl -s -X POST "${DOMAIN}/presets/" \
		-H "X-API-KEY: ${KEY}" \
		-H "Content-Type: application/json" \
		-d "{\"name\": \"$name\", \"description\": \"$description\"}")

	if echo "$create_response" | jq -e 'has("error")' > /dev/null 2>&1; then
		echo "Error creating preset:"
		echo "$create_response" | jq -r '.error'
		exit 1
	fi

	local uploadUrl
	local presetId
	uploadUrl=$(echo "$create_response" | jq -r '.uploadUrl')
	presetId=$(echo "$create_response" | jq -r '.presetId')

	# Upload the preset file
	curl -s -X PUT "$uploadUrl" --upload-file "$filepath" -H "X-API-KEY: ${KEY}"
	echo "Uploaded preset \"$name\" (ID: $presetId)"
}

cmd_delete() {
	local presetId=""
	OPTIND=1
	while getopts "p:" opt; do
		case $opt in
			p) presetId="$OPTARG" ;;
			*) echo "Usage: preset_manager.sh delete -p <presetId>"; exit 1 ;;
		esac
	done

	if [ -z "$presetId" ]; then
		echo "Error: -p <presetId> is required."
		exit 1
	fi

	local response
	response=$(curl -s -X DELETE "${DOMAIN}/presets/${presetId}" \
		-H "accept: application/json" -H "X-API-KEY: ${KEY}")
	echo "Deleted preset ${presetId}"
	echo "$response" | jq . 2>/dev/null || echo "$response"
}

# --- Main ---

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	show_help
	exit 0
fi

COMMAND="$1"
shift

parse_global_options "$@"
resolve_api_key
set -- "${REMAINING_ARGS[@]}"

case "$COMMAND" in
	list)     cmd_list "$@" ;;
	get)      cmd_get "$@" ;;
	download) cmd_download "$@" ;;
	upload)   cmd_upload "$@" ;;
	delete)   cmd_delete "$@" ;;
	*)
		echo "Unknown command: $COMMAND"
		show_help
		exit 1
		;;
esac
