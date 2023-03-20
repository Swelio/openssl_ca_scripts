#!/usr/bin/env bash

set -e

DIR='./authority'
CERT="$DIR/certs/ca.cert.pem"

if [[ ! -d $DIR ]]; then
	mkdir -p -m 0700 "$DIR/certs" "$DIR/crl" "$DIR/private" "$DIR/newcerts"
	touch "$DIR/index.txt"
	echo 00 > "$DIR/serial"
fi

openssl req -nodes -config authority.cnf -newkey ed25519 -keyout "$DIR/private/ca.key.pem" -new -x509 -days 7300 -sha512 -extensions v3_ca -out $CERT
openssl x509 -noout -text -in $CERT
