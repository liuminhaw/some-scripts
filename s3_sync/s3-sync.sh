#!/bin/bash

# Script variables
_VERSION=0.1.0

# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
show_help() {
cat << EOF
Usage: ${0##*/} [--help] [--version] pull|push
    --help                      Display this help message and exit
    --version                   Show version information
    pull                        Sync from S3 bucket to local
    push                        Sync from local to S3 bucket
EOF
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
if [[ ! -f "config" ]]; then
    echo "config not found"
    exit 2
fi
source config


_sync_direction=${1}
if [[ "${_sync_direction,,}" != "push" && "${_sync_direction,,}" != "pull" ]]; then
    echo "Parameter should be 'push' or 'pull'"
    show_help
    exit 1
fi

# aws credential
export AWS_ACCESS_KEY_ID=${_ACCESS_KEY}
export AWS_SECRET_ACCESS_KEY=${_ACCESS_SECRET}

# Sync "push"
if [[ "${_sync_direction,,}" == "push" ]]; then
    aws s3 sync ${_LOCAL} ${_S3_BUCKET} 
fi

# Sync "pull"
if [[ "${_sync_direction,,}" == "pull" ]]; then
    aws s3 sync ${_S3_BUCKET} ${_LOCAL}
fi
