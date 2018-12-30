FROM ubuntu:bionic
  
RUN apt update && \
        apt install -y \
                git \
                gcc \
                make \
                libicu-dev \
                libldap-dev \
                libxml2-dev \
                libssl-dev && \
                apt clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/openca/libpki.git -b libpki-0.9.0 && \
        cd /libpki && \
        ./configure && \
        make && \
        make install && \
        ln -s /usr/lib64/libpki.so.88 /usr/lib/libpki.so.88 && \
        ln -s /usr/lib64/libpki.so.90 /usr/lib/libpki.so.90 && \
        cd / && \
        rm -rf /libpki && \
        useradd ocspd

ADD ./run_ocspd.sh /usr/local/ocspd/run_ocspd.sh

RUN git clone https://github.com/openca/openca-ocspd.git -b openca-ocspd-3.1.2 && \
        cd /openca-ocspd && \
        ./configure --prefix=/usr/local/ocspd && \
        make && \
        make install && \
        cd .. && \
        rm -rf /usr/local/ocspd/etc/ocspd/pki/token.d/* && \
        rm -rf /usr/local/ocspd/etc/ocspd/ca.d/* && \
        rm -rf /usr/local/ocspd/etc/ocspd/ocspd.xml && \
        rm -rf /openca-ocspd && \
        mkdir -p /data/ocspd && \
        chmod +x /usr/local/ocspd/run_ocspd.sh
	
WORKDIR /usr/local/ocspd

ADD ca.xml /usr/local/ocspd/etc/ocspd/ca.d/ca.xml
ADD ocspd.xml /usr/local/ocspd/etc/ocspd/ocspd.xml
ADD token.xml /usr/local/ocspd/etc/ocspd/pki/token.d/token.xml

CMD ["/usr/local/ocspd/run_ocspd.sh"]
