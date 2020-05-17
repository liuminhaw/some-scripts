#!/bin/bash

_SCRIPT=${0}
_FIND_PATH='Enter path to be modify here'

echo "Executing script: ${_SCRIPT}"

while read _name; do
    if [[ "${_name}" == "${_SCRIPT}" ]]; then
        continue
    fi

    if [[ -d "${_name}" ]]; then
        echo "Change ${_name} permission to 755..."
        chmod 755 ${_name}
    elif [[ -f "${_name}" ]]; then
        echo "Change ${_name} permission to 644..."
        chmod 644 ${_name}
    else
        echo "${_name} not file type nor directory type"
    fi
done < <(find ${_FIND_PATH} -type f -or -type d)