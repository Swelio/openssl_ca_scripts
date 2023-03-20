#!/usr/bin/env bash

set -e

DIR='./authority'

if [[ $# -ne 1 ]];then
	echo "Usage: $(basename $0) <ca_id>"
	exit 1
fi

if [[ ! -d $DIR ]]; then
	mkdir -p -m 0700 "$DIR/certs" "$DIR/newcerts" "$DIR/crl" "$DIR/private" "$DIR/csr"
	touch "$DIR/index.txt"
	echo 00 > "$DIR/serial"
fi

CA_ID="$1"
CA_CERT="$DIR/certs/$CA_ID.cert.pem"
CA_KEY="$DIR/private/$CA_ID.key.pem"

CNAME="$(cat /proc/sys/kernel/random/uuid | sha1sum | cut -d ' ' -f1)"
NAME="$CNAME.$CA_ID"
CERT="$DIR/certs/$NAME.cert.pem"
KEY="$DIR/private/$NAME.key.pem"
CSR="$DIR/csr/$NAME.csr.pem"

openssl req -config authority.cnf -new -newkey ed25519 -nodes -keyout $KEY -out $CSR -subj "/CN=$CNAME"
openssl ca -config authority.cnf -cert $CA_CERT -keyfile $CA_KEY -extensions v3_end_cert -days 3650 -notext -in $CSR -out $CERT
openssl x509 -noout -text -in $CERT
openssl verify -CAfile "$DIR/certs/$CA_ID.chain.cert.pem" $CERT
openssl pkey -in $KEY -out "$DIR/private/$NAME.key.der" -outform DER
openssl x509 -in $CERT -out "$DIR/certs/$NAME.cert.der" -outform DER
