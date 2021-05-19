#!/bin/bash

# Script var
_VERSION=0.0.2

# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
show_help() {
cat << EOF
Usage: ${0##*/} [--help] [--version] [--snapshots|--init] [--type=local|sftp]
    --help                      Display this help message and exit
    --snapshots                 Display snapshot history from 'type' destination
    --init                      Initial backup destination
    --type=[local|sftp]         
    --type [local|sftp]         Specify backup destination type: (local, sftp)
                                Default type: local
    --version                   Show version information
EOF
}

_backup_type="local"


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
        --snapshots)
            _snapshot="true"
            ;;
        --init)
            _init="true"
            ;;
        --type)
            if [[ "${2}" ]]; then
                _backup_type=${2}
                shift
            else
                echo -e "[ERROR] '--type' requires a non-empty option argument." 1>&2
                exit 1
            fi
            ;;
        --type=?*)
            _backup_type=${1#*=} # Delete everything up to "=" and assign the remainder
            ;;
        --type=)
            echo -e "[ERROR] '--type' requires a non-empty option argument." 1>&2
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

if [[ ! -f "config" ]]; then
    echo "config not found"
    exit 1
fi
source config

if [[ ! -z "${_backup_type}" && "${_backup_type}" -ne "local" && "${_backup_type}" -ne "sftp" ]]; then
    show_help
    exit 1
fi

if [[ "${_snapshot}" == "true" && "${_init}" == "true" ]]; then
    show_help
    exit 1
fi

# Backup
if [[ "${_backup_type}" == "local" ]]; then
    _dest_repo="${_LOCAL_DEST}"
    _src_repo="${_LOCAL_SRC}"
elif [[ "${_backup_type}" == "sftp" ]]; then
    _dest_repo="sftp:${_SFTP}:${_SFTP_DEST}"
    _src_repo="${_SFTP_SRC}"
else
    echo "Invalid type parameter: ${_backup_type}"
    exit 1
fi

if [[ "${_init}" == "true" ]]; then
    restic init -r ${_dest_repo} --password-file ${_PASSWORD_FILE}
elif [[ "${_snapshot}" == "true" ]]; then
    restic snapshots -r ${_dest_repo} --password-file ${_PASSWORD_FILE}
else
    restic backup -v -r ${_dest_repo} --exclude-file="${_EXCLUDE_FILE}" --password-file ${_PASSWORD_FILE} ${_src_repo}
    restic prune -r ${_dest_repo} --password-file ${_PASSWORD_FILE}
fi
