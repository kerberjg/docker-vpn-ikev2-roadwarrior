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
    && ./configure  --enable-eap-identity --enable-eap-md5 --enable-eap-mschapv2 --enable-eap-tls --enable-eap-ttls --enable-eap-peap --enable-eap-tnc --enable-eap-dynamic --enable-eap-radius --enable-xauth-eap  --enable-dhcp  --enable-openssl  --enable-addrblock --enable-unity --enable-certexpire --enable-radattr --enable-swanctl --enable-openssl --disable-gmp \
    && make && make install

### PREPARE AND RUN
FROM alpine:latest
COPY --from=strongswan-build /usr/local /usr/local

# Install dependencies
ARG RUNTIME_DEPS="iptables libuuid openssl gettext"
RUN apk --no-cache add --virtual runtime_deps ${RUNTIME_DEPS}

## RUNTIME SETUP
ENV HOST_ADDR ''
ENV VPN_USER ''
ENV VPN_PASS ''

# Networking
EXPOSE 4500:4500/udp 500:500/udp

# Entrypoint script
ADD init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]