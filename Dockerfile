FROM ubuntu

RUN apt-get update && \
	apt-get install -y \
		gcc \
		make \
		wget \
		nano \
		libldap-dev \
		libxml2-dev \
		libssl-dev \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /usr/local/src && \
	mkdir -p /data/ocspd && \
	mkdir /openca-ocsp-master && \
	mkdir /libpki-master

RUN useradd ocspd

ADD https://github.com/openca/openca-ocspd/archive/master.tar.gz /openca-ocsp-master/

ADD https://github.com/openca/libpki/archive/master.tar.gz /libpki-master/

RUN  cd /libpki-master && \
	tar -xzf master.tar.gz && \
	cd libpki-master && \
	./configure && \
	make && \
	make install && \
	ln -s /usr/lib64/libpki.so.88 /usr/lib/libpki.so.88 && \
	ln -s /usr/lib64/libpki.so.90 /usr/lib/libpki.so.90 && \
	cd / && \
	rm -rf /libpki-master

RUN cd /openca-ocsp-master && \
	tar -xzf master.tar.gz && \
	cd openca-ocspd-master && \
	./configure --prefix=/usr/local/ocspd && \
        make && \
        make install && \
        cd / && \
        rm -rf openca-ocsp-master && \
        rm -rf /usr/local/ocspd/etc/ocspd/pki/token.d/* && \
        rm -rf /usr/local/ocspd/etc/ocspd/ca.d/* && \
        rm /usr/local/ocspd/etc/ocspd/ocspd.xml && \
	rm -rf /openca-ocsp-master

WORKDIR /usr/local/ocspd

ADD ./run_ocspd.sh /usr/local/ocspd/run_ocspd.sh
RUN chmod +x /usr/local/ocspd/run_ocspd.sh
ADD ./ca.xml /usr/local/ocspd/etc/ocspd/ca.d/ca.xml
ADD ./ocspd.xml /usr/local/ocspd/etc/ocspd/ocspd.xml
ADD ./token.xml /usr/local/ocspd/etc/ocspd/pki/token.d/token.xml

CMD ["/usr/local/ocspd/run_ocspd.sh"]
