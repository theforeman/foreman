#!/bin/sh

CN="example.com"
openssl req -new -newkey rsa:4096 -out $CN.csr -keyout $CN.key -sha256 -config openssl-san.cnf
openssl x509 -req -days 365 -sha256 -in $CN.csr -signkey $CN.key -out $CN.crt -extensions v3_req -extfile openssl-san.cnf
