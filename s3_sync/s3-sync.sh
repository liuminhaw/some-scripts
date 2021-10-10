#!/bin/bash

# Script variables
_VERSION=0.2.1


_config="config"

# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
show_help() {
cat << EOF
Usage: 
${0##*/} [--help] [--version] [--config=CONFIG_FILE] [--age=AGE_KEYFILE] push
${0##*/} [--help] [--version] [--config=CONFIG_FILE] [--age=AGE_KEYFILE] [--file-perm=NUMERIC_PERM] [--dir-perm=NUMERIC_PERM] pull
    --help                          Display this help message and exit
    --version                       Show version information
    --config=CONFIG_FILE            Specify which config file to read from
                                    Default file: config
    --age=AGE_KEYFILE               Add encryption with age using key file 
    --file-perm=NUMERIC_PERM        Set files permission to NUMERIC_PERM (Eg. 664) 
    --dir-perm=NUMERIC_PERM         Set directory permission to NUMERIC_PERM (Eg. 775)
    pull                            Sync from S3 bucket to local
    push                            Sync from local to S3 bucket
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
    local _age_file=${2}
    local _age_dir=${3}

    local _age_key=$(cat ${_age_file} | grep "public key" | cut -f 2 -d ':' | xargs)

    for _file in $(find ${_local} -type f); do
        echo "[DEBUG] encrypting ${_file}"
        _file_dir=$(dirname ${_file#"${_local}"})
        mkdir -p ${_age_dir}/${_file_dir}
        age -r ${_age_key} -o ${_age_dir}/${_file#"${_local}"}.age ${_file}
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
        if [[ "${_file##*.}" == "age" ]]; then
            echo "[DEBUG] decrypting ${_file}"
            _file_dir=$(dirname ${_file#"${_age_dir}"})
            _filename=$(basename ${_file})
            mkdir -p ${_tmp_dir}/${_file_dir}
            age --decrypt -i ${_age_key} -o ${_tmp_dir}/${_filename%".age"} ${_file}
        else 
            echo "[INFO] File ${_file} skipped, doesn't seem to be encrypted with age"
        fi
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

mod_perm() {
    if [[ ${#} -ne 3 ]]; then
        echo -e "[ERROR] Function mod_perm usage error"
        exit 4
    fi

    local _path=${1}
    local _perm=${2}
    local _type=${3}

    if [[ "${_type,,}" == "file" ]]; then
        _type="f"
    elif [[ "${_type,,}" == "directory" ]]; then
        _type="d"
    else
        echo -e "[ERROR] Third parameter in mod_perm function should be 'file' of 'directory'"
        exit 4
    fi

    while read _name; do
        if [[ "${_name}" == "${_path}" ]]; then
            continue
        fi

        echo -e "[INFO] Change ${_name} permission to ${_perm}"
        chmod ${_perm} ${_name}
    done < <(find ${_path} -type ${_type})
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
        --file-perm)
            if [[ "${2}" ]]; then
                _file_perm=${2}
                shift
            else
                echo -e "[ERROR] '--file-perm' requires a non-empty option argument." 1>&2
                exit 1
            fi
            ;;
        --file-perm=?*)
            _file_perm=${1#*=} # Delete everything up to "=" and assign the remainder
            ;;
        --file-perm=)
            echo -e "[ERROR] '--file-perm' requires a non-empty option argument." 1>&2
            exit 1
            ;;
        --dir-perm)
            if [[ "${2}" ]]; then
                _dir_perm=${2}
                shift
            else
                echo -e "[ERROR] '--dir-perm' requires a non-empty option argument." 1>&2
                exit 1
            fi
            ;;
        --dir-perm=?*)
            _dir_perm=${1#*=} # Delete everything up to "=" and assign the remainder
            ;;
        --dir-perm=)
            echo -e "[ERROR] '--dir-perm' requires a non-empty option argument." 1>&2
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

    if [[ ! -z "${_file_perm}" ]]; then
        mod_perm ${_LOCAL} ${_file_perm} "file"
    fi

    if [[ ! -z "${_dir_perm}" ]]; then
        mod_perm ${_LOCAL} ${_dir_perm} "directory"
    fi
fi
