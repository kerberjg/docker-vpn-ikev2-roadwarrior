FROM alpine:latest as strongswan-build
LABEL author=@kerberjg

##
## BUILD AND INSTALL DEPENDENCIES
##

# Install dependencies (Alpine packages)
# TODO: consider using libressl-dev instead
ARG BUILD_DEPS="build-base curl linux-headers openssl-dev gnupg"
RUN apk --no-cache add --virtual build_deps ${BUILD_DEPS}

# Build and install Strongswan
ARG STRONGSWAN_VERSION="5.8.1"
RUN mkdir /tmp/strongswan \
    && cd /tmp \
    && curl -L "https://download.strongswan.org/strongswan-${STRONGSWAN_VERSION}.tar.gz" -o strongswan.tar.gz \
    && curl -L "https://download.strongswan.org/strongswan-${STRONGSWAN_VERSION}.tar.gz.sig" -o strongswan.tar.gz.sig \
    && gpg --receive-keys 0xb34dba77 \
    && echo hullo \
    && gpg --verify ./strongswan.tar.gz.sig \
    && tar --strip-components=1 -C /tmp/strongswan -xf /tmp/strongswan.tar.gz \
    && cd /tmp/strongswan \
    && ./configure \
    --enable-aesni \
    --enable-chapoly \
    --enable-sha3 \
    --enable-newhope \
    --enable-ntru \
#    --enable-eap-md5 \
#    --enable-eap-mschapv2 \
#    --enable-eap-identity \
#    --enable-eap-tls \
#    --enable-eap-ttls \
#    --enable-eap-peap \
#    --enable-eap-tnc \
#    --enable-eap-dynamic \
#    --enable-eap-radius \
#    --enable-xauth-eap \
    --enable-dhcp \
    --enable-openssl \
    --enable-addrblock \
    --enable-farp \
#    --enable-unity \
    --enable-radattr \
    --enable-swanctl \
    --enable-openssl \
    --disable-ikev2 \
    --disable-gmp \
    --disable-sha1 \
    --disable-sha2 \
    --disable-md5 \
    --disable-rc2 \
    --disable-rc4 \
    --disable-hmac \
    --disable-des \
    && make && make install

# TODO: revisit strongswan configuration 
    
RUN rm -rf /tmp/* \
    && apk del build_deps \
    && rm -rf /var/cache/apk/* 

###
### PREPARE AND RUN
###
FROM alpine:latest
COPY --from=strongswan-build / /

# Install dependencies
ARG RUNTIME_DEPS="iptables libuuid openssl gettext"
RUN apk --no-cache add --virtual runtime_deps ${RUNTIME_DEPS}

##
## RUNTIME SETUP
##
# Networking
EXPOSE 4500:4500/udp 500:500/udp
ENV HOST_ADDR='localhost'
ENV VPN_SUBNET='10.8.0.0/16'
ENV VPN_SUBNET_IP6="fd6a:6ce3:c8d8:7caa::/64"

ENV DNS_SERVER1="1.1.1.1"
ENV DNS_SERVER2="1.0.0.1"

# Auth
# (available modes: "SHARED_SECRET", "CERTIFICATE", "RADIUS")
#ENV AUTH_MODE="SHARED_SECRET"

# Entrypoint
ADD config /data/config
ADD bin /data/bin
RUN chmod +x /data/bin/*
ENTRYPOINT ["/data/bin/init.sh"]