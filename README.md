# CloudAPI

Usage examples for the [Perfectly Clear WebAPI](https://perfectlyclear.io/docs/).

## Prerequisites

- A Perfectly Clear API key
- `cURL` and `jq` (for bash examples)
- Node.js (for TypeScript example)

## Quick Start

1. Clone this repository.
2. Set your API key in `bash/.env`:
   ```
   APIKEY=your-api-key-here
   ```

## Examples

### Bash

Located in `bash/`. See `bash/README.md` for full details.

**Image correction** — upload an image, apply corrections, download the result:

```
cd bash
./perfectly_clear.sh input.jpg output.jpg preset=Universal
```

**Preset management** — list, view, download, upload, and delete user presets:

```
cd bash
./preset_manager.sh list
./preset_manager.sh download -p <presetId>
./preset_manager.sh upload -n "My Preset" -d "Description" -f my_preset.preset
```

Run `./preset_manager.sh -h` for all commands and options.

### TypeScript

Located in `typescript/`. A single-file example (`src/app.ts`) that demonstrates the image correction workflow using `axios`. Set your API key in the `APIKEY` constant in `app.ts` before running.

## Documentation

Full API documentation: https://perfectlyclear.io/docs/