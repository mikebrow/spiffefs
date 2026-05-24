#!/bin/bash -xe

ls -l /tmp/mnt/x509/0
openssl x509 -in /tmp/mnt/x509/0/credential-bundle.pem -noout -text
openssl x509 -in /tmp/mnt/x509/0/example.org.spiffe-trust-bundle.pem -noout -text
