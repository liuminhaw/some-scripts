#!/bin/bash

# Script variables
_VERSION=0.2.0


_config="config"

# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
show_help() {
cat << EOF
Usage: ${0##*/} [--help] [--version] [--config=CONFIG_FILE] [--age=AGE_KEYFILE] pull|push
    --help                      Display this help message and exit
    --version                   Show version information
    --config=CONFIG_FILE        Specify which config file to read from
                                Default file: config
    --age=AGE_KEYFILE           Add encryption with age using key file 
    pull                        Sync from S3 bucket to local
    push                        Sync from local to S3 bucket
EOF
}

age_check() {
    which age
    
    if [[ ${?} -ne 0 ]]; then
        echo "false"
    fi
    echo "true"
}

age_encrypt() {
    if [[ ${#} -ne 3 ]]; then
        echo -e "[ERROR] Function age_encrypt usage error"
        exit 3
    fi

    local _local=${1}
    local _age_key=${2}
    local _age_dir=${3}

    for _file in $(find ${_local} -type f); do
        echo "[DEBUG] encrypting ${_file}"
        _file_dir=$(dirname ${_file#"${_local}"})
        mkdir -p ${_age_dir}/${_file_dir}
        age -R ${_age_key} -o ${_age_dir}/${_file#"${_local}"}.age ${_file}
    done
}

age_decrypt() {
    if [[ ${#} -ne 2 ]]; then
        echo -e "[ERROR] Function age_decrypt usage error"
        exit 3
    fi

    local _age_key=${1}
    local _age_dir=${2}
    local _tmp_dir="/tmp/$(date +%s).age"

    for _file in $(find ${_age_dir} -type f); do
        echo "[DEBUG] decrypting ${_file}"
        _file_dir=$(dirname ${_file#"${_age_dir}"})
        _filename=$(basename ${_file})
        mkdir -p ${_tmp_dir}/${_file_dir}
        age --decrypt -i ${_age_key} -o ${_tmp_dir}/${_filename%".age"} ${_file}
    done

    rm -rf ${_age_dir}
    mv ${_tmp_dir} ${_age_dir}
}

age_clean() {
    if [[ ${#} -ne 1 ]]; then
        echo -e "[ERROR] Function age_clean usage error"
        exit 3
    fi

    local _age_dir=${1}

    rm -rf ${_age_dir}
}

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
                _config=${2}
                shift
            else
                echo -e "[ERROR] '--config' requires a non-empty option argument." 1>&2
                exit 1
            fi
            ;;
        --config=?*)
            _config=${1#*=} # Delete everything up to "=" and assign the remainder
            ;;
        --config=)
            echo -e "[ERROR] '--config' requires a non-empty option argument." 1>&2
            exit 1
            ;;
        --age)
            if [[ "${2}" ]]; then
                _age=${2}
                shift
            else
                echo -e "[ERROR] '--age' requires a non-empty option argument." 1>&2
                exit 1
            fi
            ;;
        --age=?*)
            _age=${1#*=} # Delete everything up to "=" and assign the remainder
            ;;
        --age=)
            echo -e "[ERROR] '--age' requires a non-empty option argument." 1>&2
            exit 1
            ;;
        -?*)
            echo -e "[WARN] Unknown option (ignored): ${1}" 1>&2
            exit 1
            ;;
        *)  # Default case: no more options
            break
    esac

    shift
done

# Check required parameter
if [[ "${#}" -ne 1 ]]; then
    show_help
    exit 1
fi

# Read configuration
if [[ ! -f "${_config}" ]]; then
    echo "config file: ${_config} not found"
    exit 2
fi
source ${_config}

_sync_direction=${1}
if [[ "${_sync_direction,,}" != "push" && "${_sync_direction,,}" != "pull" ]]; then
    echo "Parameter should be 'push' or 'pull'"
    show_help
    exit 1
fi

# age encryption
if [[ ! -z "${_age}" ]]; then
    which age > /dev/null
    if [[ ${?} -ne 0 ]]; then
        echo "age not found. Please install age before using --age option"
        exit 3
    fi
    if [[ ! -f "${_age}" ]]; then
        echo "age key file: ${_age} not found"
        exit 3
    fi
fi


# aws credential
export AWS_ACCESS_KEY_ID=${_ACCESS_KEY}
export AWS_SECRET_ACCESS_KEY=${_ACCESS_SECRET}

# Sync "push"
if [[ "${_sync_direction,,}" == "push" ]]; then
    if [[ ! -z "${_age}" ]]; then
        _age_dir="/tmp/$(date +%s).age"
        age_encrypt ${_LOCAL} ${_age} ${_age_dir}
        aws s3 sync ${_age_dir} ${_S3_BUCKET}
        age_clean ${_age_dir}
    else
        aws s3 sync ${_LOCAL} ${_S3_BUCKET} 
    fi
fi

# Sync "pull"
if [[ "${_sync_direction,,}" == "pull" ]]; then
    if [[ ! -z "${_age}" ]]; then
        _age_dir="/tmp/$(date +%s).age"
        mkdir ${_age_dir}
        aws s3 sync ${_S3_BUCKET} ${_age_dir}
        age_decrypt ${_age} ${_age_dir}
        rsync -aqz ${_age_dir}/ ${_LOCAL}/
        age_clean ${_age_dir}
    else
        aws s3 sync ${_S3_BUCKET} ${_LOCAL}
    fi
fi
