#!/usr/bin/env bash

CA_DIR='./ca'
CA_CERT="$CA_DIR/certs/ca.cert.pem"

if [[ ! -d $CA_DIR ]];then
	mkdir -p -m 0700 $CA_DIR/certs $CA_DIR/crl $CA_DIR/private $CA_DIR/newcerts
	touch $CA_DIR/index.txt
	echo 00 > $CA_DIR/serial
fi

openssl req -config ca.cnf -newkey ed25519 -keyout $CA_DIR/private/ca.key.pem -new -x509 -days 7300 -sha512 -extensions v3_ca -out $CA_CERT
openssl x509 -noout -text -in $CA_CERT
