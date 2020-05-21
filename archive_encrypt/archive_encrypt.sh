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
# Version: 0.2.0


# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
show_help() {
cat << EOF
Usage: ${0##*/} [--help] [--version] [--config=CONFIG_FILE] OUTPUT_FILENAME SOURCES...
Usage: ${0##*/} --decrypt [--config=CONFIG_FILE] ENCRYPTED_SOURCE

    --help                  Display this help message and exit
    --config=CONFIG_FILE
    --config CONFIG_FILE    Secify config file to read when running the script
                            Default config file: ./archive_encrypt.conf
    --decrypt               Run decrytion from encrypted file
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
        echo "Usage: random_password PASSWORD_LENGTH [CHARACTER_SET]" 1>&2
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


# ---------------------------------------------------------------
# Function definition
#
# Usage: tee_logger LEVEL MESSAGE LOG_PATH
#
# LEVEL:
#   - echo (STDOUT, lblue)
#   - status (STDOUT, lcyan)
#   - info (STDOUT, orange)
#   - warning (STDERR, yellow)
#   - error (STDERR, lred)
# ---------------------------------------------------------------
logger_switch() {

    if [[ "${#}" -ne 3 && "${#}" -ne 2 ]]; then
        echo "Usage: tee_logger LEVEL MESSAGE [LOG_PATH]" 1>&2
        exit 12
    fi

    _nc='\033[0m'
    _orange='\033[0;33m'
    _lred='\033[1;31m'
    _yellow='\033[1;33m'
    _lblue='\033[1;34m'
    _lcyan='\033[1;36m'

    _level=${1}
    _message=${2}

    _datetime=$(date +%Y-%m-%d\ %H:%M:%S)

    if [[ "${#}" -eq 3 ]]; then
        _log_path=${3}
        _log_dir=$(dirname ${_log_path})
    fi

    if [[ ! -d "${_log_dir}" || "${#}" -eq 2 ]]; then
        case ${_level,,} in
            status)
                echo -e "${_lcyan}${_message}${_nc}" 
                ;;
            echo)
                echo -e "${_lblue}==> ${_nc}${_message}" 
                ;;
            info)
                echo -e "[${_orange}INFO${_nc}] ${_message}" 
                ;;
            warning)
                echo -e "[${_yellow}WARN${_nc}] ${_message}" 1>&2
                ;;
            error)
                echo -e "[${_lred}ERROR${_nc}] ${_message}" 1>&2
                ;;
            *)
                echo -e "[${_lred}ERROR${_nc}] ${_message}" 1>&2
                ;;
        esac
    else
        case ${_level,,} in
            status)
                echo "[${_datetime}] ${_message}" >> ${_log_path}
                ;;
            echo)
                echo "==> [${_datetime}] ${_message}" >> ${_log_path}
                ;;
            info)
                echo "[INFO] [${_datetime}] ${_message}" >> ${_log_path}
                ;;
            warning)
                echo "[WARN] [${_datetime}] ${_message}" >> ${_log_path}
                ;;
            error)
                echo "[ERROR] [${_datetime}] ${_message}" >> ${_log_path}
                ;;
            *)
                echo "[ERROR] [${_datetime}] ${_message}" >> ${_log_path}
        esac
    fi
}


# Environment variables
_VERSION="0.2.0"
_SCRIPT=$(basename ${0})

_CONFIG_FILE=./archive_encrypt.conf
_DECRYPTION="false"
_TEMP_SOURCE="/tmp/archive-encrypt_$(date +%Y%m%d-%H%M%S)"

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
                echo -e "[ERROR] '--config' requires a non-empty option argument." 1>&2
                exit 1
            fi
            ;;
        --config=?*)
            _CONFIG_FILE=${1#*=} # Delete everything up to "=" and assign the remainder
            ;;
        --config=)
            echo -e "[ERROR] '--config' requires a non-empty option argument." 1>&2
            exit 1
            ;;
        --decrypt)
            _DECRYPTION="true"
            ;;
        -?*)
            echo -e "[WARN] Unknown option (ignored): ${1}" 1>&2
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
    echo -e "[Info] ${_CONFIG_FILE} file for configuration not found" 1>&2
    exit 2
fi
source ${_CONFIG_FILE}

# tar command
which tar 1> /dev/null
if [[ "${?}" -ne 0 ]]; then
    logger_switch info "No such command: tar" ${_OUTPUT_LOG}
    exit 3
fi
# gpg command
which gpg 1> /dev/null
if [[ "${?}" -ne 0 ]]; then
    logger_switch info "No such command: gpg" ${_OUTPUT_LOG}
    exit 3
fi

# Destination directory
if [[ -z "${_DESTINATION_DIR}" || ! -d "${_DESTINATION_DIR}" ]]; then
    logger_switch info "Config _DESTINATION_DIR no value or not exist" ${_OUTPUT_LOG}
    exit 4
fi

# if [[ "${_DECRYPTION}" == "false" && "${#}" -lt 2 ]]; then
#     show_help
#     exit 1
# elif [[ "${_DECRYPTION}" == "true" && "${#}" -ne 1 ]]; then
#     show_help
#     exit 1
# fi

if [[ "${_DECRYPTION}" == "false" && "${#}" -ge 2 ]]; then
    # Valid encryption input
    _output_filename=${1}
    _output_fullpath=${_DESTINATION_DIR}/${_output_filename}

    shift 1
    _sources=${@}
elif [[ "${_DECRYPTION}" == "true" && "${#}" -eq 1 ]]; then
    # Valid decryption input
    _source=${1}
else
    show_help
    exit 1
fi

# Archive and encryption process
if [[ "${_DECRYPTION}" == "false" ]]; then
    logger_switch echo "Archive and encrypt start" ${_OUTPUT_LOG}

    # Temp source directory
    if [[ -d "${_TEMP_SOURCE}" ]]; then
        logger_switch info "${_TEMP_SOURCE} already exist" ${_OUTPUT_LOG}
        exit 5 
    fi
    mkdir ${_TEMP_SOURCE}

    # Passphrase file 
    # Generate random passphrase if no passphrase commited
    if [[ -z "${_PASSPHRASE_FILE}" || ! -f "${_PASSPHRASE_FILE}" ]]; then
        _passphrase=$(random_password 21)
    fi

    # Check compress method
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

    for _source in ${_sources}; do
        if [[ ! -e "${_source}" ]]; then
            logger_switch info "Source ${_source} does not exist" ${_OUTPUT_LOG}
            logger_switch info "Skip ${_source}" ${_OUTPUT_LOG}
            continue
        fi

        # Copy source to temp source destination
        cp -r ${_source} ${_TEMP_SOURCE}
    done

    # Avoid for empty source directory 
    if [[ ! "$(ls -A ${_TEMP_SOURCE})" ]]; then
        logger_switch info "All sources not exist, skip process." 
        rmdir ${_TEMP_SOURCE}
        exit 6
    fi

    # Avoid gpg encryption file duplicates
    if [[ -f "${_output_fullpath}.gpg" ]]; then
        rm ${_output_fullpath}.gpg
    fi

    # Archive and encrypt
    logger_switch status "Archiving..." ${_OUTPUT_LOG}
    tar ${_tar_option} ${_output_fullpath} -C ${_TEMP_SOURCE} .

    logger_switch status "Encrypting..." ${_OUTPUT_LOG}
    if [[ -z "${_passphrase}" ]]; then
        gpg -c --batch --passphrase-file ${_PASSPHRASE_FILE} ${_output_fullpath}
    else
        gpg -c --batch --passphrase "${_passphrase}" ${_output_fullpath}
        logger_switch status "" ${_OUTPUT_LOG}
        logger_switch echo "Passphrase: ${_passphrase}" ${_OUTPUT_LOG}
    fi

    logger_switch status "Cleanup..." ${_OUTPUT_LOG}
    rm ${_output_fullpath}
    rm -rf ${_TEMP_SOURCE}

    logger_switch echo "Archive and encrypt done" ${_OUTPUT_LOG}
fi

# Decryption process
if [[ "${_DECRYPTION}" == "true" ]]; then
    logger_switch echo "Decryption start" ${_OUTPUT_LOG}

    if [[ ! -f "${_source}" || "${_source##*.}" != "gpg" ]]; then
        logger_switch warning "Input source is not a valid file" ${_OUTPUT_LOG}
        exit 6
    elif [[ "${_source##*.}" != "gpg" ]]; then
        logger_switch warning "Input source file should end with extension .gpg" ${_OUTPUT_LOG}
        exit 6
    fi

    # Decrypt
    logger_switch status "Decrypting..." ${_OUTPUT_LOG}
    _output_filename=$(basename ${_source%.*})
    _output_fullpath=${_DESTINATION_DIR}/${_output_filename}

    # Check output file existence
    if [[ -f "${_output_fullpath}" ]]; then
        logger_switch info "${_output_fullpath} existed, will be overwritten" ${_OUTPUT_LOG}
        rm ${_output_fullpath}
    fi

    if [[ -z "${_PASSPHRASE_FILE}" || ! -f "${_PASSPHRASE_FILE}" ]]; then
        read -sp 'Decrypt password: ' _passphrase
        echo ""
        gpg -qo ${_output_fullpath} -d --batch --passphrase "${_passphrase}" ${_source}
    else
        gpg -qo ${_output_fullpath} -d --batch --passphrase-file ${_PASSPHRASE_FILE} ${_source}
    fi

    # Check decrypt result
    if [[ ${?} -ne 0 ]]; then
        logger_switch error "Failed to decrypt file" ${_OUTPUT_LOG}
        exit 7
    fi

    logger_switch echo "Decryption done" ${_OUTPUT_LOG}
fi