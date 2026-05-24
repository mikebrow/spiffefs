#!/bin/bash -xe

ls -l /tmp/mnt/x509/0
ls -l /tmp/mnt/x509/1
diff -u <(echo main; echo other) <(sort -u /tmp/mnt/x509/*/hint)

cp /tmp/mnt/x509/0/credential-bundle.pem /tmp
[[ $(openssl x509 -noout -modulus -in /tmp/credential-bundle.pem | openssl md5) == $(openssl rsa -noout -modulus -in credential-bundle.pem | openssl md5) ]]
cp /tmp/mnt/x509/1/credential-bundle.pem /tmp
[[ $(openssl x509 -noout -modulus -in /tmp/credential-bundle.pem | openssl md5) == $(openssl rsa -noout -modulus -in credential-bundle.pem | openssl md5) ]]
#FIXME check svids
