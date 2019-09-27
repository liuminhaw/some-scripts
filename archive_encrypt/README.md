# Archive and Encrypt
Archive and encrypt single source file or directory 

## Version
In Development (Program roughly working)

### TODOs
**v0.1.0**
- Optional compress method (issue #2)
- Random passphrase if passphrase file not exist (issue #1)

## Setup
Run `setup.sh` script for installation
```sh
./setup.sh DESTINATION_DIR
```

## Configuration
`archive_encrypt.conf`
- `_DESTINATION_DIR` : Encrypted file output directory 
- `_ENCRYPT_METHOD` : gzip / bzip2 / xz (TODOs - Not functional yet)
- `_PASSPHRASE_FILE` : Passphrase storing file which is use for encryption

## Usage
```sh
./archive_encrypt.sh OUTPUT_FILENAME SOURCE
```