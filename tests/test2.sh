#!/bin/bash -xe

ls -l /tmp/mnt/x509/0
ls -l /tmp/mnt/x509/1
diff -u <(echo main; echo other) <(sort -u /tmp/mnt/x509/*/hint)
#FIXME check svids
