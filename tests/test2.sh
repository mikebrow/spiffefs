#!/bin/bash -xe

# Check for 2 svids, both with hints. Main is federated.

ls -l /tmp/mnt/x509/0
ls -l /tmp/mnt/x509/1
diff -u <(echo main; echo other) <(sort -u /tmp/mnt/x509/*/hint)

cat /tmp/mnt/x509/0/credential-bundle.pem > /tmp/credential-bundle.pem
[[ $(openssl x509 -noout -in /tmp/credential-bundle.pem | openssl md5) == $(openssl pkey -noout -in /tmp/credential-bundle.pem | openssl md5) ]]
openssl verify -CAfile /tmp/mnt/x509/0/example.org.spiffe-trust-bundle.pem -untrusted /tmp/credential-bundle.pem /tmp/credential-bundle.pem
cat /tmp/mnt/x509/1/credential-bundle.pem > /tmp/credential-bundle.pem
[[ $(openssl x509 -noout -in /tmp/credential-bundle.pem | openssl md5) == $(openssl pkey -noout -in /tmp/credential-bundle.pem | openssl md5) ]]
openssl verify -CAfile /tmp/mnt/x509/1/example.org.spiffe-trust-bundle.pem -untrusted /tmp/credential-bundle.pem /tmp/credential-bundle.pem

main=$(dirname "$(grep -l "main" /tmp/mnt/x509/*/*hint 2>/dev/null | head -n 1)")
other=$(grep -l "other" /tmp/mnt/x509/*/*hint | xargs -I {} dirname {}/credential-bundle.pem)
other=$(dirname "$(grep -l "other" /tmp/mnt/x509/*/*hint 2>/dev/null | head -n 1)")
openssl x509 -in "$main/credential-bundle.pem" -noout -text | grep URI:spiffe://example.org/test2/main
openssl x509 -in "$other/credential-bundle.pem" -noout -text | grep URI:spiffe://example.org/test2/other

openssl x509 -in "$main/other.org.spiffe-trust-bundle.pem" -noout -text | grep URI:spiffe://other.org
