#!/bin/bash -xe

entries=$(ls -l /tmp/mnt/x509 | wc -l)
if [ $entries -ne 0 ]; then
	echo There should not be any entries
	exit 1
fi
