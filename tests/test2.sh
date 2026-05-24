#!/bin/bash -xe

ls -l /tmp/mnt/x509/0
ls -l /tmp/mnt/x509/1
diff -u <(echo main; echo other) <(sort -u /tmp/mnt/x509/*/hint)

cat /tmp/mnt/x509/0/credential-bundle.pem > /tmp/credential-bundle.pem
[[ $(openssl x509 -noout -in /tmp/credential-bundle.pem | openssl md5) == $(openssl pkey -noout -in /tmp/credential-bundle.pem | openssl md5) ]]
cat /tmp/mnt/x509/1/credential-bundle.pem > /tmp/credential-bundle.pem
[[ $(openssl x509 -noout -in /tmp/credential-bundle.pem | openssl md5) == $(openssl pkey -noout -in /tmp/credential-bundle.pem | openssl md5) ]]


main=$(grep -l "main" /tmp/mnt/x509/*/*hint | xargs -I {} dirname {}/credential-bundle.pem)
other=$(grep -l "other" /tmp/mnt/x509/*/*hint | xargs -I {} dirname {}/credential-bundle.pem)
openssl x509 -in "$main" -noout -text | grep URI:spiffe://example.org/test2/main
openssl x509 -in "$other" -noout -text | grep URI:spiffe://example.org/test2/other
