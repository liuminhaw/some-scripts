# Archive and Encrypt
Archive and encrypt source files and directories

## Version
#### v0.2.0
- New script `archive_encrypt-s.sh`
    - Integrate `archive_encrypt.sh` with multiple config files
- New options added to `archive_encrypt.sh`
    - `--sources`
    - `--compress`

v0.1.3
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
```
Usage: setup.sh simple|full DESTINATION

    simple            Simple function setup for only archive_encrypt
    full              Full function setup for multiple configs ability
```

## Configuration
Configuration file need to be update if current version < v0.2.0

#### archive_encrypt-s.conf
```bash
# archive_encrypt-s.conf

# Directory where all config files are located
_CONFIGS=conf.d

# Optional: Postfix type for output filename
# Options
#   - date: filename_YYYY-mm-dd
#   - datetime: filename_YYYYmmdd-HHMMSS
# Default: no postfix
_OUTPUT_POSTFIX=

# Optional: output log file location
# output to STDOUT and STDERR if not given
_OUTPUT_LOG=
```

#### archive_encrypt.conf / *.conf
```bash
# conf.template

# environment variables configuration
# _DESTINATION_DIR=/destination/example
_DESTINATION_DIR=

# Optional: Given sources (as an array)
# _SOURCES=(source1 source2 source3 ...)
_SOURCES= 

# Optional: Generate random passphrase if not given
_PASSPHRASE_FILE=

# Optional: gzip, bzip2, xz
# Default: no compression
_COMPRESS_METHOD= 

# Optional: output log file location
# output to STDOUT and STDERR if not given
_OUTPUT_LOG
```


## Usage

#### archive_encrypt-s.sh
```bash
Usage: ./archive_encrypt-s.sh [--help] [--version]

    --help                      Display this help message and exit
    --version
```

#### archive_encrypt.sh
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
 
- 11 - Function error: random_password
- 12 - Function error: logger_switch

- 21 - Library script not found