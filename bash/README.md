# Perfectly Clear API Bash Usage Example

This script automates the process of enhancing images using the Perfectly Clear API. It downloads an image from a given URL, uploads it to the Perfectly Clear service, applies predefined correction parameters, and then downloads the enhanced image.

## Requirements

•   `cURL`: This script uses curl for HTTP requests.

•   `jq`: JSON parsing is done through jq. Please ensure it's installed on your system.

## Usage

1.  Set up the `APIKEY` with your Perfectly Clear API key.
2.  Configure the `INPUT_URL` variable with the URL of the image you want to correct.
3.  Run the script by executing `./app.sh`

## Environmental Variables

•  `DOMAIN`: The endpoint domain for the Perfectly Clear API.

•  `APIKEY`: Your personal API key for accessing the Perfectly Clear API.

•  `INPUT_URL`: The URL of the image that you wish to process.

•  `INPUT_FILE`: Local path where the input image will be saved.

•  `OUTPUT_FILE`: Local path where the enhanced image will be saved.

## Optional Configuration

•   `FILE_TYPE`: The type of file being processed (default is 'image').

•   `CORRECTION_PARAMETERS`: Correction parameters for the image enhancement.

## Functions

•   `downloadFile` downloads the image from the specified URL.

•   `getPreSignedURL` retrieves the pre-signed URL for uploading the image.

•   `uploadFile` uploads the image to the Perfectly Clear storage.

•   `startCorrection` starts the image correction process with Perfectly Clear.

•   `statusUpdate` repeatedly checks the status of the correction until it's completed.

## Output

The script will save two images:

•   The original image from the `INPUT_URL`.

•   The enhanced image after correction by Perfectly Clear API.

## Notes

•   Ensure that the `APIKEY` is kept secret and not exposed publicly.
