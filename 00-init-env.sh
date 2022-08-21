#!/bin/bash

[ ! -z ./xx-vars.sh ] && echo "Environment already setup.  Nothing to do" && exit 1

# default xx-vars config.
ENV_GROUP_ID=$(id -g)
ANACONDA_VERSION="3-2022.05"
ANACONDA_ARCH="x86_64"
ANACONDA_OS="Linux"
DOCKER_SSL_EXPIREDAYS=700
DOCKER_SSL_SERVERIP="127.0.0.1"
DOCKER_SSL_NAME="Docker Desktop - Federated SSL CA"
DOCKER_SSL_CASUBJECTSTRING="/C=US/ST=California/L=Los\ Angeles/O=Sabertooth\ Media\ Group\ \,\ LLC/OU=IT/CN=sabertoothmediagroup.net/emailAddress=cert@sabertoothmediagroup.net"

# the following vars are not editable here as they are generated by code one time.  if you have already
# run this script and have an xx-vars.sh in the current directory, please edit that.
ANACONDA_FILENAME="Anaconda${ANACONDA_VERSION}-${ANACONDA_OS}-${ANACONDA_ARCH}.sh"
ANACONDA_URL="https://repo.anaconda.com/archive/${ANACONDA_FILENAME}"
WSL_USERPROFILE=$(wslpath -a $(wslvar USERPROFILE))
DOCKER_SSL_CERT_PATH=${WSL_USERPROFILE}/.docker/machine/certs
DOCKER_SSL_FILENAME=$( wslsys -R | awk 'match($0, /^(Linux Release: )(.*)( LTS)+$/, a) {print tolower(a[2])}' | sed -e 's/\ /\-/g' )-$( echo $RANDOM | md5sum | head -c 8 )
DOCKER_SSL_PASSWORD=$( cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ' ')
ENV_USER_ID=$(id -u)

# change - persist xx-env-vars across script runs.
cat <<EOF > ./xx-vars.sh
ENV_USER_ID=${ENV_USER_ID}
ENV_GROUP_ID=${ENV_GROUP_ID}
ANACONDA_VERSION="${ANACONDA_VERSION}"
ANACONDA_ARCH="${ANACONDA_ARCH}"
ANACONDA_OS="${ANACONDA_OS}"
ANACONDA_FILENAME="${ANACONDA_FILENAME}"
ANACONDA_URL="${ANACONDA_URL}"
WSL_USERPROFILE="${WSL_USERPROFILE}"
DOCKER_SSL_NAME="${DOCKER_SSL_NAME}"
DOCKER_SSL_CERT_PATH="${DOCKER_SSL_CERT_PATH}"
DOCKER_SSL_FILENAME="${DOCKER_SSL_FILENAME}"
DOCKER_SSL_PASSWORD="${DOCKER_SSL_PASSWORD}"
DOCKER_SSL_SERVERIP="${DOCKER_SSL_SERVERIP}"
DOCKER_SSL_EXPIREDAYS=${DOCKER_SSL_EXPIREDAYS}
DOCKER_SSL_CASUBJECTSTRING="${DOCKER_SSL_CASUBJECTSTRING}"
EOF