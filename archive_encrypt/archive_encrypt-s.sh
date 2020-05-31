#!/bin/bash

# Program:
#   Multiple settings for archive and encrypt usage
# Author:
#   haw
#
# Usage:
#   archive_encrypt-s.sh
#
# Version: 0.2.0

# Environment variables
_VERSION="0.2.0"
_CONFIG_FILE=./archive_encrypt-s.conf
_ARCHIVE_ENCRYPT=./lib/archive_encrypt.sh


# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
show_help() {
cat << EOF
Usage: ${0##*/} [--help] [--version]

    --help                      Display this help message and exit
    --version                   Show version information
EOF
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
        echo "Usage: logger_switch LEVEL MESSAGE [LOG_PATH]" 1>&2
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
                echo "[${_datetime}] ==> ${_message}" >> ${_log_path}
                ;;
            info)
                echo "[${_datetime}] [INFO] ${_message}" >> ${_log_path}
                ;;
            warning)
                echo "[${_datetime}] [WARN] ${_message}" >> ${_log_path}
                ;;
            error)
                echo "[${_datetime}] [ERROR] ${_message}" >> ${_log_path}
                ;;
            *)
                echo "[${_datetime}] [ERROR] ${_message}" >> ${_log_path}
        esac
    fi
}


# --------------------
# Command line options
# --------------------
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
        *)  # Default case: no more options
            break
    esac
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

# Config directory
if [[ ! -d "${_CONFIGS}" ]]; then
    logger_switch warning "${_CONFIGS} directory for configuration files not found" ${_OUTPUT_LOG}
    exit 2
fi

# library scripts
if [[ ! -f "${_ARCHIVE_ENCRYPT}" ]]; then
    logger_switch warning "${_ARCHIVE_ENCRYPT} script not found" ${_OUTPUT_LOG}
    exit 21
fi


# ---------------
# Process configs
# ---------------

# Test empty configs
_config_files=$(find ${_CONFIGS} -type f -name "*.conf")
if [[ -z ${_config_files} ]]; then
    logger_switch info "No config file found in ${_CONFIGS}, exit" ${_OUTPUT_LOG}
    exit 2
fi

for _config in ${_config_files}; do
    logger_switch status "Config file: ${_config}" ${_OUTPUT_LOG}

    # Extract compress method from config
    _compress_cmd=$(grep ^_COMPRESS_METHOD ${_config})
    if [[ "${?}" -ne 0 ]]; then
        _COMPRESS_METHOD=
    else
        eval ${_compress_cmd} 
    fi

    # Output postfix
    case ${_OUTPUT_POSTFIX,,} in
        date)
            _file_postfix="_$(date +%Y-%m-%d)"
            ;;
        datetime)
            _file_postfix="_$(date +%Y%m%d-%H%M%S)"
            ;;
        *)
            _file_postfix=""
            ;;
    esac 

    # Output file extension
    case ${_COMPRESS_METHOD,,} in
        bzip2)
            _file_ext=".tar.bzip2"
            ;;
        xz)
            _file_ext=".tar.xz"
            ;;
        gzip)
            _file_ext=".tar.gzip"
            ;;
        *)
            _file_ext=".tar"
            ;;
    esac

    # Output filename
    _config_filename=$(basename ${_config})
    _output_file=${_config_filename//.*}${_file_postfix}${_file_ext}
    
    # Archive encrypt process
    logger_switch echo "${_ARCHIVE_ENCRYPT} --config=${_config} ${_output_file}" ${_OUTPUT_LOG}
    ${_ARCHIVE_ENCRYPT} --config=${_config} ${_output_file}

done