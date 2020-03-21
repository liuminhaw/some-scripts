#!/bin/bash

# Program:
#   Archives and encrypt target path for further use
# Author:
#   haw
#
# Usage:
#   archive_encrypt.sh OUTPUT_FILENAME SOURCE
#
# Notes:
#   - Use tar command for archive and compress
#   - Use gpg command for encryption
#
# Exit code:
#   1 - Usage error
#   2 - Config file not found
#   3 - Missing command
#   4 - Config file environment error
#   5 - Source not found
#
# Version: 0.1.1


# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
show_help() {
    echo "USAGE: ${_SCRIPT} OUTPUT_FILENAME SOURCE"
cat << EOF
Usage: ${0##*/} [--help] [--config=CONFIG_FILE] OUTPUT_FILENAME SOURCE

    --help                  Display this help message and exit
    --config=CONFIG_FILE
    --config CONFIG_FILE    Secify config file to read when running the script
                            Default config file: ./archive_encrypt.conf
EOF
}


# ----------------------------------------------------------------------------
# Function definition
#
# Usage: random_password PASSWORD_LENTGH [CHARACTER_SET]
# Return:
#   11 - usage error
# ----------------------------------------------------------------------------
random_password() {
    if [[ "${#}" -ne 1 && "${#}" -ne 2 ]]; then
        echo "Usage: random_password PASSWORD_LENGTH [CHARACTER_SET]"
        exit 11
    fi

    _length=${1}
    if [[ "${#}" -eq 2 ]]; then
        _character_set="${2}"
    else
        _character_set='a-zA-Z0-9!@#$%^&*()_+'
    fi

    echo $(cat /dev/urandom | tr -dc ${_character_set} | fold -w ${_length} | head -n 1)
}



# Environment variables
_SCRIPT=$(basename ${0})
_CONFIG_FILE=./archive_encrypt.conf

_NC='\033[0m'
_ORANGE='\033[0;33m'
_LRED='\033[1;31m'
_YELLOW='\033[1;33m'
_LBLUE='\033[1;34m'
_LCYAN='\033[1;36m'

# Command line options
while :; do
    case ${1} in
        --help)
            show_help
            exit
            ;;
        --config)
            if [[ "${2}" ]]; then
                _CONFIG_FILE=${2}
                shift
            else
                echo -e "[${_LRED}ERROR${_NC}] '--config' requires a non-empty option argument." 1>&2
                exit 1
            fi
            ;;
        --config=?*)
            _CONFIG_FILE=${1#*=} # Delete everything up to "=" and assign the remainder
            ;;
        --config=)
            echo -e "[${_LRED}ERROR${_NC}] '--config' requires a non-empty option argument." 1>&2
            exit 1
            ;;
        -?*)
            echo -e "[${_YELLOW}WARN${_NC}] Unknown option (ignored): ${1}" 1>&2
            ;;
        *)  # Default case: no more options
            break
    esac

    shift
done

# --------------------
# Requirements testing
# --------------------


# Config file
if [[ ! -f "${_CONFIG_FILE}" ]]; then
    echo -e "[${_ORANGE}Info${_NC}] ${_CONFIG_FILE} file for configuration not found"
    exit 2
fi
source ${_CONFIG_FILE}

# tar command
which tar 1> /dev/null
if [[ "${?}" -ne 0 ]]; then
    echo -e "[${_ORANGE}Info${_NC}] No such command: tar"
    exit 3
fi
# gpg command
which gpg 1> /dev/null
if [[ "${?}" -ne 0 ]]; then
    echo -e "[${_ORANGE}Info${_NC}] No such command: gpg"
    exit 3
fi

# Destination directory
if [[ -z "${_DESTINATION_DIR}" || ! -d "${_DESTINATION_DIR}" ]]; then
    echo -e "[${_ORANGE}Info${_NC}] Config _DESTINATION_DIR no value or not exist"
    exit 4
fi

# Passphrase file 
# Generate random passphrase if no passphrase commited
if [[ -z "${_PASSPHRASE_FILE}" || ! -f "${_PASSPHRASE_FILE}" ]]; then
    _passphrase=$(random_password 17)
fi

# Check encrypt method
shopt -s nocasematch
if [[ "${_COMPRESS_METHOD}" == "bzip2" ]]; then
    _tar_option='-jcf'
elif [[ "${_COMPRESS_METHOD}" == "xz" ]]; then
    _tar_option='-Jcf'
elif [[ "${_COMPRESS_METHOD}" == "gzip" ]]; then
    _tar_option='-zcf'
else 
    _tar_option='-cf'
fi


if [[ "${#}" -ne 2 ]]; then
    show_help
    exit 1
fi
_output_filename=${1}
_output_fullpath=${_DESTINATION_DIR}/${_output_filename}
_source=${2}
_source_dir=$(dirname ${_source})
_source_base=$(basename ${_source})

# Source directory/file
if [[ -e "${source}" ]]; then
    echo -e "[${_ORANGE}Info${_NC}] Source ${_source} does not exist"
    exit 5
fi

# Avoid gpg encryption file duplicates
if [[ -f "${_output_fullpath}.gpg" ]]; then
    rm ${_output_fullpath}.gpg
fi

# Archive and encrypt
echo -e "${_LCYAN}Archiving...${_NC}"
cd ${_source_dir}
tar ${_tar_option} ${_output_fullpath} ${_source_base}
cd -

echo -e "${_LCYAN}Encrypting...${_NC}"
if [[ -z "${_passphrase}" ]]; then
    gpg -c --batch --passphrase-file ${_PASSPHRASE_FILE} ${_output_fullpath}
else
    gpg -c --batch --passphrase "${_passphrase}" ${_output_fullpath}
    echo
    echo -e "${_LBLUE}==> ${_NC}Passphrase: ${_passphrase}"
fi
rm ${_output_fullpath}

echo
echo -e "${_LCYAN}Archive and encrypt done${_NC}"