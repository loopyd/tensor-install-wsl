#!/bin/bash

ENV_USER_ID=$(id -u)
ENV_GROUP_ID=$(id -g)

ANACONDA_VERSION="3-2022.05"
ANACONDA_ARCH="x86_64"
ANACONDA_OS="Linux"

# These are autogenerated environment variables, please don't mess with them.
ANACONDA_FILENAME="Anaconda${ANACONDA_VERSION}-${ANACONDA_OS}-${ANACONDA_ARCH}.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_FILENAME}"

WSL_USERPROFILE=$(wslpath -a $(wslvar USERPROFILE))
DOCKER_SSL_CERT_PATH=${WSL_USERPROFILE}/.docker/machine/certs
DOCKER_SSL_FILENAME=$( wslsys -R | awk 'match($0, /^(Linux Release: )(.*)( LTS)+$/, a) {print tolower(a[2])}' | sed -e 's/\ /\-/g' )-$( echo $RANDOM | md5sum | head -c 8 )
