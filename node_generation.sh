#!/usr/bin/env bash

CA_CERT="./intermerdiate/certs/ca.cert.pem"
DIR='./intermediate'
COMMON_NAME="$(python -c 'import uuid; print(uuid.uuid4().hex)')"
NODE_CERT="$DIR/certs/$COMMON_NAME.cert.pem"

if [[ ! -d $DIR ]]; then
	mkdir -p -m 0700 $DIR/certs $DIR/newcerts $DIR/crl $DIR/private $DIR/csr
	touch $DIR/index.txt
	echo 00 > $DIR/serial
fi

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <CAId>"
	exit 1
fi

CAfile="$DIR/certs/$1.cert.pem"
KeyFile="$DIR/private/$1.key.pem"

openssl req -config intermediate.cnf -new -newkey ed25519 -nodes -keyout $DIR/private/$COMMON_NAME.key.pem -out $DIR/csr/$COMMON_NAME.csr.pem -subj "/CN=$COMMON_NAME"
openssl ca -config intermediate.cnf -cert $CAfile -keyfile $KeyFile -extensions multi_cert -days 3650 -notext -in $DIR/csr/$COMMON_NAME.csr.pem -out $NODE_CERT
openssl x509 -noout -text -in $NODE_CERT
openssl verify -CAfile "$DIR/certs/chain_$1.cert.pem" $NODE_CERT
