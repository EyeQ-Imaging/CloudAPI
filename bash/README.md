# Perfectly Clear API Bash Examples

Bash scripts for interacting with the Perfectly Clear API. Includes image correction and user preset management.

## Requirements

•   `cURL`: Used for making HTTP requests.

•   `jq`: Needed for JSON parsing.

•   `.env`: A file storing environment variables including the API key.

## Setup

1.  Update `.env` with your Perfectly Clear API key (`APIKEY`) and optionally a custom endpoint (`APIENDPOINT`).
2.  Ensure you have `cURL` and `jq` installed on your system.

## Image Correction

`perfectly_clear.sh` uploads an image, applies correction parameters, and downloads the result.

```
./perfectly_clear.sh INPUT_FILE OUTPUT_FILE [CORRECTION_PARAMETERS]
```

•   `INPUT_FILE`: Path to the local image file, or a previously uploaded fileKey.

•   `OUTPUT_FILE`: Path where the enhanced image will be saved.

•   `CORRECTION_PARAMETERS` (optional): Additional parameters for image correction.

Example:

```
./perfectly_clear.sh input.jpg output.jpg preset=Universal
```

## Preset Management

`preset_manager.sh` manages user presets on the Perfectly Clear API.

```
./preset_manager.sh <command> [options]
```

### Commands

**List all presets:**

```
./preset_manager.sh list
```

**Get metadata for a preset:**

```
./preset_manager.sh get -p <presetId>
```

**Download a preset file:**

```
./preset_manager.sh download -p <presetId> [-o <output_file>]
```

If `-o` is omitted, the file is saved as `<presetId>.preset`.

**Upload a new preset:**

```
./preset_manager.sh upload -n <name> -d <description> -f <file>
```

**Delete a preset:**

```
./preset_manager.sh delete -p <presetId>
```

### Options

•   `-k <apikey>`: Override the API key from `.env` for a single command.

•   `-h`: Show help.

## Notes

•   Keep the API key confidential and avoid exposing it publicly.

•   Ensure the `.env` file is properly formatted and stored securely.