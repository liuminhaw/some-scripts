#!/bin/bash
#
# Program:
#   archive_encrypt setup script
#
# Exit Code:
#   1 - Calling syntax error
#   3 - Destination directory does not exist
#
#   11 - Copy file failed
#   13 - Change file permission failed


# ============================
# Check exit code function
# USAGE:
#   checkCode EXITCODE MESSAGE
# ============================
function checkCode() {
  if [[ ${?} -ne 0 ]]; then
    echo ${2}
    exit ${1}
  fi
}

# ===========================
# Usage: Installation DESTDIR 
# ===========================
function Installation() {
    DESTDIR=${1}

    # Setup process
    cp README.md ${DESTDIR}
    checkCode 11 "Copy README.md failed." &> /dev/null
    cp archive_encrypt.sh ${DESTDIR}
    checkCode 11 "Copy archive_encrypt.sh failed."  &> /dev/null
    chmod 755 ${DESTDIR}/archive_encrypt.sh
    checkCode 13 "Change file permission failed."   &> /dev/null

    if [[ ! -f ${DESTDIR}/archive_encrypt.conf ]]; then
        cp archive_encrypt.conf ${DESTDIR}/archive_encrypt.conf
        checkCode 11 "Copy archive_encrypt.conf failed."  &> /dev/null
        chmod 644 ${DESTDIR}/archive_encrypt.conf
        checkCode 13 "Change file permission failed."
    fi
}


# Calling setup format check
USAGE="setup.sh DESTINATION"

if [[ "${#}" -ne 1 ]];  then
    echo -e "USAGE:\n    ${USAGE}"
    exit 1
fi

if [[ ! -d ${1} ]]; then
    echo "ERROR: Destination directory does not exist"
    exit 3
fi


# System checking
SYSTEM_RELEASE=$(uname -a)
case ${SYSTEM_RELEASE} in
  *Linux*)
    echo "Linux detected"
    echo ""
    Installation ${1}
    ;;
  *)
    echo "System not supported."
    exit 1
esac


echo "archive_encrypt setup success."
exit 0