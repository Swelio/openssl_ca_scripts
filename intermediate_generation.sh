#!/usr/bin/env bash

CA_CERT="./ca/certs/ca.cert.pem"
INTER_DIR='./intermediate'
INTER_NAME="$(date +%s)"
INTER_CERT="$INTER_DIR/certs/$INTER_NAME.cert.pem"
INTER_CHAIN=$INTER_DIR/certs/chain_${INTER_NAME}.cert.pem

if [[ ! -d $INTER_DIR ]]; then
	mkdir -p -m 0700 $INTER_DIR/certs $INTER_DIR/newcerts $INTER_DIR/crl $INTER_DIR/private $INTER_DIR/csr
	touch $INTER_DIR/index.txt
	echo 00 > $INTER_DIR/serial
fi

openssl req -config intermediate.cnf -new -newkey ed25519 -nodes -keyout $INTER_DIR/private/$INTER_NAME.key.pem -out $INTER_DIR/csr/$INTER_NAME.csr.pem
openssl ca -config ca.cnf -extensions v3_intermediate_ca -days 3650 -notext -in $INTER_DIR/csr/$INTER_NAME.csr.pem -out $INTER_CERT
openssl x509 -noout -text -in $INTER_CERT
cat $CA_CERT $INTER_CERT > $INTER_CHAIN
openssl verify -CAfile $INTER_CHAIN $INTER_CERT
