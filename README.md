# UniFi Backup Explorer Tool

A pure **clientside JavaScript** tool to decrypt and explore UniFi network backup files (.unf) in your browser.

## Features

✅ **No server required** - Everything runs in your browser  
✅ **Secure decryption** - Uses AES-128-CBC with hardcoded UniFi keys  
✅ **File extraction** - Explores ZIP archive contents  
✅ **Metadata display** - Shows backup file info  
✅ **File preview** - View text, JSON, images, and BSON database info  

## How It Works

UniFi backup files (.unf) are encrypted using AES-128-CBC with a static key and IV hardcoded in the UniFi software:

- **Key**: `bcyangkmluohmars` (16 bytes)
- **IV**: `ubntenterpriseap` (16 bytes)
- **Mode**: CBC with NoPadding
- **Result**: A ZIP archive containing backup data

The tool:
1. Reads the encrypted .unf file
2. Decrypts using AES-128-CBC (CryptoJS library)
3. Extracts files from the resulting ZIP
4. Displays file list and metadata
5. Allows preview of file contents

## Supported Backup Versions

Works with UniFi backups from v7.0 and later (likely earlier versions too, as the encryption key is static and hardcoded).

Tested with: **v9.5.21**

## Backup Contents

UniFi backups typically contain:

- `db.gz` - Main database (MongoDB BSON, gzipped)
- `db_stat.gz` - Statistics database
- `version` - UniFi version info
- `format` - Format version identifier
- `timestamp` - Backup timestamp
- `system.properties` - System configuration
- `sites/` - Per-site configuration and databases

## Using the Tool

### Browser Usage

1. Open `backup-explorer.html` in a modern web browser
2. Click the drop zone or select a `.unf` backup file
3. Wait for decryption and extraction
4. Click file names to preview contents

### Database Files (BSON)

UniFi uses MongoDB with BSON-encoded databases. To convert BSON to JSON:

```bash
# Install MongoDB tools (if not already installed)
sudo apt install mongodb-database-tools  # Linux
brew install mongodb-database-tools      # macOS

# Convert BSON database to JSON
bsondump db.gz > backup.json
```

Or use an online BSON to JSON converter.

## Technical Details

### Encryption

- **Algorithm**: AES-128 (Rijndael with 128-bit key)
- **Mode**: CBC (Cipher Block Chaining)
- **Padding**: None (NoPadding)
- **Key Derivation**: Static - no derivation, hardcoded in UniFi software

### Decryption Command (OpenSSL)

```bash
openssl enc -d -in backup.unf -out backup.zip -aes-128-cbc \
  -K 626379616e676b6d6c756f686d617273 \
  -iv 75626e74656e74657270726973656170 -nopad
```

### Libraries Used

- **CryptoJS 4.2.0** - AES-128-CBC decryption
- **JSZip 3.10.1** - ZIP file parsing and extraction

## Privacy & Security

✅ **No data is sent to any server**  
✅ **All processing happens in your browser**  
✅ **No cookies or tracking**  
✅ **Open source - inspect the code**  

## Browser Compatibility

Works on any modern browser supporting:
- ES6+ JavaScript
- ArrayBuffer / Uint8Array
- Web Crypto (for CryptoJS)

Tested on:
- Chrome/Chromium 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Files

- `backup-explorer.html` - Main tool (single HTML file with embedded CSS and JavaScript)
- `test-decrypt.html` - Simple decryption test page
- `README.md` - This file

## Troubleshooting

### "Unable to decrypt .unf file"

The decryption uses static keys from UniFi source code. If decryption fails:
1. Ensure the file is a valid `.unf` backup from UniFi
2. Check the browser console (F12) for error messages
3. The file might be from an unsupported UniFi version (though unlikely)

### "ZIP has structural issues"

Some UniFi backup versions have slightly malformed ZIP end-of-central-directory records. JSZip usually handles this gracefully. If files don't show:
1. Try decrypting with OpenSSL instead (see command above)
2. File might be corrupted

### Cannot view BSON files

BSON files are binary MongoDB databases. Convert them using:
- `bsondump` (from MongoDB tools)
- Online BSON converters
- `mongodump` (if you have MongoDB running)

## References

- [UniFi Backup Decrypt (GitHub)](https://github.com/zhangyoufu/unifi-backup-decrypt)
- [CryptoJS Documentation](https://cryptojs.gitbook.io/)
- [JSZip Documentation](https://stuk.github.io/jszip/)
- [MongoDB BSON Specification](https://bsonspec.org/)

## License

This tool is provided as-is for exploring your own UniFi backups. Respect copyright and only decrypt backups you have permission to access.

## Version History

### v1.0 (Initial Release)
- Static AES-128-CBC decryption
- ZIP extraction and file listing
- File preview for text and images
- BSON database info
- Works with UniFi v7-v9.5+

---

**Made with ❤️ for UniFi users**  
No warranty - use at your own risk
