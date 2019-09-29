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
#   4 - COnfig file environment error



# Environment variables
_SCRIPT=$(basename ${0})
_CONFIG_FILE=./archive_encrypt.conf

# ====================
# Requirements testing
# ====================
# Config file
if [[ ! -f "${_CONFIG_FILE}" ]]; then
    echo "Info: ${_CONFIG_FILE} file for configuration not found"
    exit 2
fi
source ${_CONFIG_FILE}

# tar command
which tar 1> /dev/null
if [[ "${?}" -ne 0 ]]; then
    echo "No such command: tar"
    exit 3
fi
# gpg command
which gpg 1> /dev/null
if [[ "${?}" -ne 0 ]]; then
    echo "No such command: gpg"
    exit 3
fi

# Destination directory
if [[ -z "${_DESTINATION_DIR}" || ! -d "${_DESTINATION_DIR}" ]]; then
    echo "Info: Config _DESTINATION_DIR no value or not exist"
    exit 4
fi
# Passphrase file 
if [[ -z "${_PASSPHRASE_FILE}" || ! -f "${_PASSPHRASE_FILE}" ]]; then
    echo "Info: Config _PASSPHRASE_FILE no value or not exist"
    exit 4
fi

# Check encrypt method
shopt -s nocasematch
if [[ "${_ENCRYPT_METHOD}" == "bzip2" ]]; then
    _tar_option='-jcf'
elif [[ "${_ENCRYPT_METHOD}" == "xz" ]]; then
    _tar_option='-Jcf'
else 
    _tar_option='-zcf'
fi


if [[ "${#}" -ne 2 ]]; then
    echo "USAGE: ${_SCRIPT} OUTPUT_FILENAME SOURCE"
    exit 1
fi
_output_filename=${1}
_output_fullpath=${_DESTINATION_DIR}/${_output_filename}
_source=${2}

# Avoid gpg encryption file duplicates
if [[ -f "${_output_fullpath}.gpg" ]]; then
    rm ${_output_fullpath}.gpg
fi

# Archive and encrypt
echo "Archiving..."
tar ${_tar_option} ${_output_fullpath} ${_source}
echo "Encrypting..."
gpg -c --batch --passphrase-file ${_PASSPHRASE_FILE} ${_output_fullpath}
rm ${_output_fullpath}

echo "Archive and encrypt done"