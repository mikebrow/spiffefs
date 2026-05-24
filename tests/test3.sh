#!/bin/bash -xe

if [ -z "$(find /tmp/mnt/x509 -maxdepth 0 -empty)" ]; then
	echo There should not be any entries
	ls -l /tmp/mnt/x509
	exit 1
fi
