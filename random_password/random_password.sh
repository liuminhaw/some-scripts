#!/bin/bash

# Version: 0.1.0

# Usage: ./random-password.sh LENGTH
_SCRIPT=$(basename ${0})

if [[ "${#}" -ne 1 ]]; then
    echo "Usage: ${_SCRIPT} PASSWORD_LENGTH"
    exit 1
fi

_length=${1}

password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#%^&*()_+' | fold -w ${_length} | head -n 1)
echo ${password}
