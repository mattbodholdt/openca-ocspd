FROM debian:stable-slim

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y \
		curl \
		gcc \
		libicu-dev \
		libldap-dev \
		libssl-dev \
		libxml2-dev \
		make \
		net-tools && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -o libpki.tar.gz  https://codeload.github.com/openca/libpki/tar.gz/refs/tags/v0.9.2 && \
	tar -xzf libpki.tar.gz && \
	cd /libpki-0.9.2 && \
	sed -i 's/strncpy( ret, my_search, strlen(my_search) );/strcpy( ret, my_search );/' src/pki_config.c && \
	./configure && \
	make && \
	make install && \
	ln -s /usr/lib64/libpki.so.92 /usr/lib/libpki.so.92 && \
	cd / && \
	rm -f /libpki.tar.gz && \
	rm -rf /libpki-0.9.2

RUN curl -o openca-ocspd.tar.gz https://codeload.github.com/openca/openca-ocspd/tar.gz/refs/tags/v3.1.3 && \
	tar -xzf openca-ocspd.tar.gz && \
	cd /openca-ocspd-3.1.3 && \
	./configure --prefix=/usr/local/ocspd && \
  	make && \
  	make install && \
  	cd / && \
	rm -rf /usr/local/ocspd/etc/ocspd/pki/token.d/* && \
	rm -rf /usr/local/ocspd/etc/ocspd/ca.d/* && \
	rm -rf /usr/local/ocspd/etc/ocspd/ocspd.xml && \
	rm -f /openca-ocspd.tar.gz && \
	rm -rf /openca-ocspd-3.1.3

COPY ca.xml /usr/local/ocspd/etc/ocspd/ca.d/ca.xml
COPY ocspd.xml /usr/local/ocspd/etc/ocspd/ocspd.xml
COPY token.xml /usr/local/ocspd/etc/ocspd/pki/token.d/token.xml
COPY test_ocspd.sh /usr/local/ocspd/test_ocspd.sh

RUN useradd ocspd && \
    chown -R ocspd:ocspd /usr/local/ocspd/

ENTRYPOINT [ "/usr/local/ocspd/sbin/ocspd", "-stdout", "-c", "/usr/local/ocspd/etc/ocspd/ocspd.xml" ]
