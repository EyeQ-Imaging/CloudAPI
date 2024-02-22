# Perfectly Clear API Node.js Usage Example

This example demonstrates how to use the Perfectly Clear API to automatically correct an image using Node.js, Axios for HTTP requests, and the fs module for file system operations.

## Prerequisites

•   Node.js installed on your machine (version >= 20.11.1)

•   An API key from Perfectly Clear API (assign it to APIKEY variable).

## Installation

Before running the script, ensure you install the dependencies:

``
yarn
``

## Usage

1.  Set the APIKEY variable with your Perfectly Clear API key.
2.  To use a different input image, change the INPUT_URL.
3.  Run the script with Node.js:

``
ts-node src/app.ts
``

The script performs the following steps:

•   Downloads an image from a given URL.

•   Uploads the image to the Perfectly Clear API.

•   Begins the correction process using specified parameters.

•   Polls for the status of the correction until completion.

•   Downloads the corrected image to the specified output path.

## Functions

### downloadFile(url: string, filePath: string)

Downloads a file from a URL and saves it locally.

### getPreSignedURL()

Retrieves a pre-signed URL for uploading the image to the Perfectly Clear server.

### uploadFile(inputFile: string, uploadUrl: string)

Uploads a local image file to a pre-signed URL obtained from the Perfectly Clear server.

### startCorrection(fileKey: string)

Initiates the image correction process on the Perfectly Clear server.

### statusUpdate(statusEndpoint: string)

Checks the status of the image processing task until it is completed.

### sleep()

Pauses execution for a set duration; used between status checks.

## Notes

•   Ensure that the APIKEY is kept secret and not exposed publicly.

•   This script uses async/await patterns, which require Node.js version 7.6 or higher.

•   The FILE_TYPE and CORRECTION_PARAMETERS are pre-set in this script. Modify them according to the desired input and correction settings as per the API documentation.
