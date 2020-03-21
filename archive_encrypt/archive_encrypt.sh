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
#   5 - Temp source directory exist
#   6 - Skip process with no sources
#
# Version: 0.1.2


# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
show_help() {
cat << EOF
Usage: ${0##*/} [--help] [--version] [--config=CONFIG_FILE] OUTPUT_FILENAME SOURCES...

    --help                  Display this help message and exit
    --config=CONFIG_FILE
    --config CONFIG_FILE    Secify config file to read when running the script
                            Default config file: ./archive_encrypt.conf
    --version               Show version information
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
_VERSION="0.1.2"
_SCRIPT=$(basename ${0})

_CONFIG_FILE=./archive_encrypt.conf
_TEMP_SOURCE="/tmp/archive-envcrypt_$(date +%Y%m%d-%H%M%S)"

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
        --version)
            echo "Version: ${_VERSION}"
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

# Temp source directory
if [[ -d "${_TEMP_SOURCE}" ]]; then
    echo -e "[${_ORANGE}Info${_NC}] ${_TEMP_SOURCE} already exist"
    exit 5 
fi
mkdir ${_TEMP_SOURCE}

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


if [[ "${#}" -lt 2 ]]; then
    show_help
    exit 1
fi
_output_filename=${1}
_output_fullpath=${_DESTINATION_DIR}/${_output_filename}

shift 1
_sources=${@}

for _source in ${_sources}; do
    if [[ ! -e "${_source}" ]]; then
        echo -e "[${_ORANGE}Info${_NC}] Source ${_source} does not exist"
        echo -e "${_LBLUE}==>${_NC} Skip ${_source}"
        continue
    fi

    # Copy source to temp source destination
    cp -r ${_source} ${_TEMP_SOURCE}
done

# _source_dir=$(dirname ${_source})
# _source_base=$(basename ${_source})

# Source directory/file
# if [[ -e "${source}" ]]; then
#     echo -e "[${_ORANGE}Info${_NC}] Source ${_source} does not exist"
#     exit 5
# fi

# Avoid for empty source directory 
if [[ ! "$(ls -A ${_TEMP_SOURCE})" ]]; then
    echo -e "[${_ORANGE}Info${_NC}] All sources not exist, skip process." 
    rmdir ${_TEMP_SOURCE}
    exit 6
fi

# Avoid gpg encryption file duplicates
if [[ -f "${_output_fullpath}.gpg" ]]; then
    rm ${_output_fullpath}.gpg
fi

# Archive and encrypt
echo -e "${_LCYAN}Archiving...${_NC}"
tar ${_tar_option} ${_output_fullpath} -C ${_TEMP_SOURCE} .

echo -e "${_LCYAN}Encrypting...${_NC}"
if [[ -z "${_passphrase}" ]]; then
    gpg -c --batch --passphrase-file ${_PASSPHRASE_FILE} ${_output_fullpath}
else
    gpg -c --batch --passphrase "${_passphrase}" ${_output_fullpath}
    echo
    echo -e "${_LBLUE}==> ${_NC}Passphrase: ${_passphrase}"
fi

echo -e "${_LCYAN}Cleanup...${_NC}"
rm ${_output_fullpath}
rm -rf ${_TEMP_SOURCE}

echo
echo -e "${_LCYAN}Archive and encrypt done${_NC}"
