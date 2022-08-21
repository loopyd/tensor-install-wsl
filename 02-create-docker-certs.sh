#!/bin/bash

# 99-install-docker-certs.sh
# code taken from:  https://github.com/kekru/linux-utils/blob/master/cert-generate/create-certs.sh
#
# Modified to integrate into script chain without command line arguments by:
# 	saber7ooth <nightwintertooth@gmail.com>
#
# You should update SSL_* portion of xx-vars.sh to override my defaults. 

. ./xx-vars.sh

function usage {
    exit 1
}

function createCA {
    openssl genrsa -aes256 -passout pass:$DOCKER_SSL_PASSWORD -out $DOCKER_SSL_CERT_PATH/ca-key.pem 4096
    openssl req -passin pass:$DOCKER_SSL_PASSWORD -new -x509 -days $DOCKER_SSL_EXPIREDAYS -key $DOCKER_SSL_CERT_PATH/ca-key.pem -sha256 -out $DOCKER_SSL_CERT_PATH/ca.pem -subj $SSL_CASUBJECTSTRING
    
    chmod 0400 $DOCKER_SSL_CERT_PATH/ca-key.pem
    chmod 0444 $DOCKER_SSL_CERT_PATH/ca.pem
}

function checkCAFilesExist {
    if [[ ! -f "$DOCKER_SSL_CERT_PATH/ca.pem" || ! -f "$DOCKER_SSL_CERT_PATH/ca-key.pem" ]]; then
        echo "$DOCKER_SSL_CERT_PATH/ca.pem or $DOCKER_SSL_CERT_PATH/ca-key.pem not found. Create CA first with '-m ca'"
        exit 1
    fi
}

function createServerCert {
    checkCAFilesExist

    if [[ -z $DOCKER_SSL_SERVERIP ]]; then
        IPSTRING=""
    else
        IPSTRING=",IP:$DOCKER_SSL_SERVERIP"
    fi

    openssl genrsa -out $DOCKER_SSL_CERT_PATH/server-key.pem 4096
    openssl req -subj "/CN=$DOCKER_SSL_NAME" -new -key $DOCKER_SSL_CERT_PATH/server-key.pem -out $DOCKER_SSL_CERT_PATH/server.csr
    echo "subjectAltName = DNS:$DOCKER_SSL_NAME$IPSTRING" > $DOCKER_SSL_CERT_PATH/extfile.cnf
    openssl x509 -passin pass:$DOCKER_SSL_PASSWORD -req -days $DOCKER_SSL_EXPIREDAYS -in $DOCKER_SSL_CERT_PATH/server.csr -CA $DOCKER_SSL_CERT_PATH/ca.pem -CAkey $DOCKER_SSL_CERT_PATH/ca-key.pem -CAcreateserial -out $DOCKER_SSL_CERT_PATH/server-cert.pem -extfile $DOCKER_SSL_CERT_PATH/extfile.cnf

    rm $DOCKER_SSL_CERT_PATH/server.csr $DOCKER_SSL_CERT_PATH/extfile.cnf $DOCKER_SSL_CERT_PATH/ca.srl
    chmod 0400 $DOCKER_SSL_CERT_PATH/server-key.pem
    chmod 0444 $DOCKER_SSL_CERT_PATH/server-cert.pem
}

function createClientCert {
    checkCAFilesExist

    openssl genrsa -out $DOCKER_SSL_CERT_PATH/client-key.pem 4096
    openssl req -subj "/CN=$DOCKER_SSL_NAME" -new -key $DOCKER_SSL_CERT_PATH/client-key.pem -out $DOCKER_SSL_CERT_PATH/client.csr
    echo "extendedKeyUsage = clientAuth" > $DOCKER_SSL_CERT_PATH/extfile.cnf
    openssl x509 -passin pass:$DOCKER_SSL_PASSWORD -req -days $DOCKER_SSL_EXPIREDAYS -in $DOCKER_SSL_CERT_PATH/client.csr -CA $DOCKER_SSL_CERT_PATH/ca.pem -CAkey $DOCKER_SSL_CERT_PATH/ca-key.pem -CAcreateserial -out $DOCKER_SSL_CERT_PATH/client-cert.pem -extfile $DOCKER_SSL_CERT_PATH/extfile.cnf

    rm $DOCKER_SSL_CERT_PATH/client.csr $DOCKER_SSL_CERT_PATH/extfile.cnf $DOCKER_SSL_CERT_PATH/ca.srl
    chmod 0400 $DOCKER_SSL_CERT_PATH/client-key.pem
    chmod 0444 $DOCKER_SSL_CERT_PATH/client-cert.pem

    mv $DOCKER_SSL_CERT_PATH/client-key.pem $DOCKER_SSL_CERT_PATH/client-$DOCKER_SSL_NAME-key.pem
    mv $DOCKER_SSL_CERT_PATH/client-cert.pem $DOCKER_SSL_CERT_PATH/client-$DOCKER_SSL_NAME-cert.pem 
}

mkdir -p $DOCKER_SSL_CERT_PATH

createCA
createServerCert
createClientCert
