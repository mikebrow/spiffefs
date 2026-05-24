#!/bin/bash -xe

ls -l /tmp/mnt/x509/0
ls -l /tmp/mnt/x509/1
sort -u /tmp/mnt/x509/*/hint
#openssl x509 -in /tmp/mnt/x509/0/credential-bundle.pem -noout -text | grep URI:spiffe://example.org/test2
#openssl x509 -in /tmp/mnt/x509/0/example.org.spiffe-trust-bundle.pem -noout -text | grep URI:spiffe://example.org
