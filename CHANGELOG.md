# Changelog

## v2.0.1
- Maximum call stack size exceeded fix
    - Replaced the String.fromCharCode.apply(null, data) conversion with a safe Uint8Array→WordArray helper
    - Added uint8ArrayToWordArray to build CryptoJS WordArrays without apply
- Enhance file input styling and functionality

## v2.0.0 (Initial Release)
- Added BSON to JSON conversion in browser
- Automatic DEFLATE decompression for ZIP-compressed files
- Gzip decompression with proper magic byte detection
- Data descriptor handling for ZIP files
- Download fixed ZIP with all decompressed files
- CRC-32 validation for reconstructed ZIPs
- Enhanced file preview with hex dumps
- Improved error handling and logging

## v1.0 (Pre-release)
- Static AES-128-CBC decryption
- ZIP extraction and file listing
- File preview for text and images
- BSON database info
- Works with UniFi v7-v9.5+