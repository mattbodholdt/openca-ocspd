#!/bin/bash

cd /usr/local/ocspd/

if [ -f "/data/ocspd/ca.crt" ]
then
	if [ ! -f "/usr/local/ocspd/etc/ocspd/certs/ca.crt" ]
	then
		ln -s /data/ocspd/ca.crt /usr/local/ocspd/etc/ocspd/certs/ca.crt
	fi
else
	echo "/data/ocspd/ca.crt not found: please add volume /data/ocspd/ with ca.crt, ocspd.crt, ocspd.key and crl.crl to container"
	exit 1
fi

if [ -f "/data/ocspd/ocspd.crt" ]
then
	if [ ! -f "/usr/local/ocspd/etc/ocspd/certs/ocspd.crt" ]
	then
		ln -s /data/ocspd/ocspd.crt /usr/local/ocspd/etc/ocspd/certs/ocspd.crt
	fi
else
	echo "/data/ocspd/ocspd.crt not found: please add volume /data/ocspd/ with ca.crt, ocspd.crt, ocspd.key and crl.crl to container"
	exit 1
fi

if [ -f "/data/ocspd/ocspd.key" ]
then
	if [ ! -f "/usr/local/ocspd/etc/ocspd/private/ocspd.key" ]
	then
		ln -s /data/ocspd/ocspd.key /usr/local/ocspd/etc/ocspd/private/ocspd.key
	fi
else
	echo "/data/ocspd/ocspd.key not found: please add volume /data/ocspd/ with ca.crt, ocspd.crt, ocspd.key and crl.crl to container"
	exit 1
fi

if [ -f "/data/ocspd/crl.crl" ]
then
	if [ ! -f "/usr/local/ocspd/etc/ocspd/crls/crl.crl" ]
	then
		ln -s /data/ocspd/crl.crl /usr/local/ocspd/etc/ocspd/crls/crl.crl
	fi
else
	echo "/data/ocspd/crl.crl not found: please add volume /data/ocspd/ with ca.crt, ocspd.crt, ocspd.key and crl.crl to container"
	exit 1
fi

chown -R ocspd:ocspd /usr/local/ocspd/

sleep 1

/usr/local/ocspd/sbin/ocspd -stdout -c /usr/local/ocspd/etc/ocspd/ocspd.xml

