import axios from 'axios';
import fs from 'fs';

const DOMAIN = 'https://api.perfectlyclear.io';
const APIKEY = '';

const INPUT_URL =
    'https://eyeq.photos/wp-content/uploads/2022/07/pfc-home-perfect-landscapes-before-min.jpg';
const INPUT_FILE = './input-image.jpg';
const OUTPUT_FILE = './output-image.jpg';

const FILE_TYPE = 'image';
const CORRECTION_PARAMETERS = '&preset=Universal';

(async () => {
    const { uploadUrl, fileKey } = await getPreSignedURL();

    await downloadFile(INPUT_URL, INPUT_FILE);

    await uploadFile(INPUT_FILE, uploadUrl);

    const { statusEndpoint } = await startCorrection(fileKey);

    await statusUpdate(statusEndpoint);

    await downloadFile(statusEndpoint, OUTPUT_FILE);
})();

async function downloadFile(url: string, filePath: string): Promise<void> {
    const file = await axios({
        method: 'GET',
        url,
        responseType: 'arraybuffer',
    });
    await fs.writeFileSync(filePath, file.data);
    console.log(`Image from ${url} saved to ${filePath}`);
}

async function getPreSignedURL(): Promise<{
    fileKey: string;
    uploadUrl: string;
}> {
    const config = {
        headers: {
            'X-API-KEY': APIKEY,
            Accept: 'application/json',
        },
    };
    const result = await axios.get(`${DOMAIN}/v2/upload`, config);
    console.log(`Pre-signed URL received from Perfectly Clear API`);
    return {
        fileKey: result.data.fileKey,
        uploadUrl: result.data.upload_url,
    };
}

async function uploadFile(inputFile: string, uploadUrl: string, ): Promise<void> {
    const data = fs.readFileSync(inputFile);
    const req = axios.create();
    delete req.defaults.headers.put['Content-Type'];
    await req.put(uploadUrl, data);
    console.log(`Image from ${inputFile} uploaded to Perfectly Clear storage`);
}

async function startCorrection(
    fileKey: string,
): Promise<{ statusEndpoint: string }> {
    const config = {
        headers: {
            'X-API-KEY': APIKEY,
            Accept: 'application/json',
        },
    };
    const result = await axios.get(
        `${DOMAIN}/v2/pfc?fileType=${FILE_TYPE}&fileKey=${fileKey}${CORRECTION_PARAMETERS}`,
        config,
    );
    const statusEndpoint = result.data.statusEndpoint;
    console.log(statusEndpoint);

    return { statusEndpoint };
}

async function statusUpdate(statusEndpoint: string): Promise<void> {
    let status = '';
    while (status !== 'COMPLETED') {
        const result = await axios.get(statusEndpoint + '?noRedirect=true');
        status = result?.data?.status;
        console.log(`Current correction status is: ${status}`);
        await sleep();
    }
}

function sleep(): Promise<void> {
    const SECOND_IN_MS = 1000;
    return new Promise((resolve) => setTimeout(resolve, SECOND_IN_MS));
}
