#!/usr/bin/env bash

set -e

DIR='./authority'
CA_CERT="$DIR/certs/ca.cert.pem"
NAME="$(date +%s | sha1sum | cut -d' ' -f1)"
CERT="$DIR/certs/$NAME.cert.pem"
CSR="$DIR/csr/$NAME.csr.pem"
CHAIN="$DIR/certs/$NAME.chain.cert.pem"

mkdir -p -m 0700 "$DIR/certs" "$DIR/newcerts" "$DIR/crl" "$DIR/private" "$DIR/csr"

openssl req -config authority.cnf -new -newkey ed25519 -nodes -keyout "$DIR/private/$NAME.key.pem" -out $CSR -subj "/CN=$NAME"
openssl ca -config authority.cnf -extensions v3_intermediate_ca -days 3650 -notext -in $CSR -out $CERT
openssl x509 -noout -text -in $CERT
openssl verify -CAfile $CA_CERT $CERT
cat $CA_CERT $CERT > $CHAIN
openssl verify -CAfile $CHAIN $CERT
