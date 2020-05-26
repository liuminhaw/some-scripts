# Archive and Encrypt
Archive and encrypt source files and directories

## Version
#### v0.1.3
- Separate logging format between standard and files

v0.1.2
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
Configuration file need to be update if current version < v0.1.3

`archive_encrypt.conf`
- `_DESTINATION_DIR` : Encrypted file output directory 
- `_COMPRESS_METHOD` : gzip / bzip2 / xz (Default - no compression)
- `_PASSPHRASE_FILE` : Passphrase storing file which is use for encryption
    - Generate random passphrase if not given
- `_OUTPUT_LOG` :  stdout log file location
    - Output to STDOUT if not given
- `_ERROR_LOG` : stderr log file location
    - Output to STDERR if not given

## Usage
```bash
Usage: ./archive_encrypt.sh [--help] [--config=CONFIG_FILE] OUTPUT_FILENAME SOURCE

    --help                  Display this help message and exit
    --config=CONFIG_FILE
    --config CONFIG_FILE    Secify config file to read when running the script
                            Default config file: ./archive_encrypt.conf
    --version               Show version information
```


## Exit Code
- 1 - Usage error
- 2 - Config file/directory not found
- 3 - Missing command
- 4 - Config file setting error
- 5 - Temp source directory exist
- 6 - Input source error
- 7 - Decryption error
- 
- 11 - Function error: random_password
- 12 - Function error: logger_switch

- 21 - Library script not found