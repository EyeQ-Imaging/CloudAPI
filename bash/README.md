# Perfectly Clear API Bash Usage Example

This script automates the process of enhancing images using the Perfectly Clear API. It uploads local file to the Perfectly Clear service, applies predefined correction parameters, and then downloads the enhanced image.

## Requirements

•   `cURL`: Used for making HTTP requests.

•   `jq`: Needed for JSON parsing.

•   `.env`: A file storing environment variables including the API key.

## Setup

1.  Update .env file with your Perfectly Clear API key (APIKEY)
2.  Ensure you have cURL and jq installed on your system.
3.  Make the script executable by running `./app.sh`

## Usage

Run the script with the following syntax:

``
./script.sh INPUT_FILE OUTPUT_FILE [CORRECTION_PARAMETERS]
``

•   `INPUT_FILE`: The path to the local image file to be processed.

•   `OUTPUT_FILE`: The path where the enhanced image will be saved.

•   `[CORRECTION_PARAMETERS]` (optional): Additional parameters for image correction.

Example: 

``
./script.sh input.jpg output.jpg preset=Universal
``

## Functions

•   `downloadFile`: Downloads the image from the specified URL.

•   `getPreSignedURL`: Retrieves the pre-signed URL for uploading the image.

•   `uploadFile`: Uploads the image to the Perfectly Clear storage.

•   `startCorrection`: Initiates the image correction process.

•   `statusUpdate`: Checks the status of the correction until completion.

## Output

The script saves the enhanced image at the `OUTPUT_FILE` path after processing.

## Notes

•   Keep the API key confidential and avoid exposing it publicly.

•   Ensure the `.env` file is properly formatted and stored securely.