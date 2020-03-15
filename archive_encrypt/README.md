# Archive and Encrypt
Archive and encrypt single source file or directory 

## Version
**v0.1.1**
- Can set to read source from other location

v0.1.0

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
Usage: ./archive_encrypt.sh [--help] [--config=CONFIG_FILE] OUTPUT_FILENAME SOURCE

    --help                  Display this help message and exit
    --config=CONFIG_FILE
    --config CONFIG_FILE    Secify config file to read when running the script
                            Default config file: ./archive_encrypt.conf
```