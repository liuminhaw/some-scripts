#!/bin/bash
#
# Program:
#   archive_encrypt setup script
#
# Exit Code:
#   1 - Calling syntax error
#   3 - Destination directory does not exist
#   5 - Unknown script bug
#
#   11 - Copy file failed
#   13 - Change file permission failed


# ----------------------------------------------------------------------------
# Function definition
#
# Usage: show_help
# ----------------------------------------------------------------------------
showHelp() {
cat << EOF
Usage: ${0##*/} simple|full DESTINATION

    simple            Simple function setup for only archive_encrypt
    full              Full function setup for multiple configs ability
EOF
}


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

# ================================
# Function for simple installation
# Usage: 
#   simpleInstallation DESTDIR 
# ================================
function simpleInstallation() {
  DESTDIR=${1}

  # Setup process
  cp README.md ${DESTDIR}
  checkCode 11 "Copy README.md failed." &> /dev/null
  cp lib/archive_encrypt.sh ${DESTDIR}
  checkCode 11 "Copy archive_encrypt.sh failed."  &> /dev/null
  chmod 755 ${DESTDIR}/archive_encrypt.sh
  checkCode 13 "Change file permission failed."   &> /dev/null

  if [[ ! -f ${DESTDIR}/archive_encrypt.conf ]]; then
    cp conf.d/conf.template ${DESTDIR}/archive_encrypt.conf
    checkCode 11 "Copy archive_encrypt.conf failed."  &> /dev/null
    chmod 644 ${DESTDIR}/archive_encrypt.conf
    checkCode 13 "Change file permission failed."
  fi
}

# ==============================
# Function for full installation
# Usage:
#   fullInstallation DESTDIR
# ==============================
function fullInstallation() {
  DESTDIR=${1}

  # Setup process
  cp README.md ${DESTDIR}
  checkCode 11 "Copy README.md failed." &> /dev/null
  cp archive_encrypt-s.sh ${DESTDIR}
  checkCode 11 "Copy archive_encrypt-s.sh failed." &> /dev/null
  cp -r lib ${DESTDIR}
  checkCode 11 "Copy lib failed." &> /dev/null

  if [[ ! -d ${DESTDIR}/conf.d ]]; then
    cp -r conf.d ${DESTDIR}
    checkCode 11 "Copy conf.d failed." &> /dev/null
  fi

  if [[ ! -f ${DESTDIR}/archive_encrypt-s.conf ]]; then
    cp archive_encrypt-s.conf ${DESTDIR}/archive_encrypt-s.conf
    checkCode 11 "Copy archive_encrypt-s.conf failed." &> /dev/null
  fi
}

# Calling setup format check
if [[ "${#}" -ne 2 ]];  then
  showHelp
  exit 1
fi

DESTINATION=${2}
if [[ ! -d ${DESTINATION} ]]; then
  echo "ERROR: Destination directory does not exist"
  exit 3
fi

# Setup checking
SETUP_TYPE=${1}
case ${SETUP_TYPE} in
  simple)
    INSTALL_TYPE="simple"
    ;;
  full)
    INSTALL_TYPE="full"
    ;;
  *)
    showHelp
    exit 1
    ;;
esac


# System checking
SYSTEM_RELEASE=$(uname -a)
case ${SYSTEM_RELEASE} in
  *Linux*)
    echo "Linux detected"
    echo ""
    if [[ "${INSTALL_TYPE}" == "simple" ]]; then
      simpleInstallation ${DESTINATION}
    elif [[ "${INSTALL_TYPE}" == "full" ]]; then
      fullInstallation ${DESTINATION}
    else
      echo "There might be some bug in setup script"
      exit 5
    fi
    ;;
  *)
    echo "System not supported."
    exit 1
esac


echo "archive_encrypt setup success."
exit 0