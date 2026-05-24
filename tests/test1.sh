#!/bin/bash -xe

# Check for only one svid without hints.

ls -l /tmp/mnt/x509/0
openssl x509 -in /tmp/mnt/x509/0/credential-bundle.pem -noout -text | grep URI:spiffe://example.org/test1
openssl x509 -in /tmp/mnt/x509/0/example.org.spiffe-trust-bundle.pem -noout -text | grep URI:spiffe://example.org
[[ ! -e "/tmp/mnt/x509/0/hint" ]]
[[ ! -d "/tmp/mnt/x509/1" ]]
