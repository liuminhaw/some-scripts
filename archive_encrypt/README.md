# Archive and Encrypt
Archive and encrypt source files and directories

## Version
#### v0.1.2
- Ability to archive multiple sources
- No compression option when archiving
- Colored output
- `version` option to show version information 

v0.1.1
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
- `_COMPRESS_METHOD` : gzip / bzip2 / xz (Default - no compression)
- `_PASSPHRASE_FILE` : Passphrase storing file which is use for encryption
    - Generate random passphrase if not given

## Usage
```bash
Usage: ./archive_encrypt.sh [--help] [--config=CONFIG_FILE] OUTPUT_FILENAME SOURCE

    --help                  Display this help message and exit
    --config=CONFIG_FILE
    --config CONFIG_FILE    Secify config file to read when running the script
                            Default config file: ./archive_encrypt.conf
    --version               Show version information
```