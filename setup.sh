#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

OPENSSL_VERSION_LIST=(
    "1.0.1"
    "1.0.1a"
    "1.0.1b"
    "1.0.1c"
    "1.0.1d"
    "1.0.1e"
    "1.0.1f"
    "1.0.1g"
    "1.0.1h"
    "1.0.1i"
    "1.0.1j"
    "1.0.1k"
    "1.0.1l"
    "1.0.1m"
    "1.0.1n"
    "1.0.1o"
    "1.0.1p"
    "1.0.1q"
    "1.0.1r"
    "1.0.1s"
    "1.0.1t"
    "1.0.1u"
)

echo "Start setup of the virtual machine..."


echo -e "${GREEN}[+][+][+][+] INSTALLING PHP [+][+][+][+]${NC}"
sudo apt-get install php-fpm

DEFAULT_OPENSSL_VERSION="1.0.1u"

echo -e "${GREEN}[+][+][+][+] DOWNGRADING OPENSSL [+][+][+][+]${NC}"
wget --no-check-certificate https://www.openssl.org/source/openssl-$DEFAULT_OPENSSL_VERSION.tar.gz
openssldir="$(pwd)"
tar -zxf openssl-$DEFAULT_OPENSSL_VERSION.tar.gz
rm openssl-$DEFAULT_OPENSSL_VERSION.tar.gz

if [ -z $1 ]; then
    OPENSSL_VERSION=$DEFAULT_OPENSSL_VERSION
else
    for version in "${OPENSSL_VERSION_LIST[@]}"; do
        if [ "$1" == "$version" ]; then
            OPENSSL_VERSION="$1"
            echo -e "${GREEN}[+][+][+][+] DOWNGRADING OPENSSL [+][+][+][+]${NC}"
            wget --no-check-certificate https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
            openssldir="$(pwd)"
            tar -zxf openssl-$OPENSSL_VERSION.tar.gz
            rm openssl-$OPENSSL_VERSION.tar.gz
            break
        fi
    done
fi

# In older versions of OpenSSL (from 1.0.1 to 1.0.1g) the pod files present some syntax errors.
# Normally we would run the sudo make install_sw so that the manuals and docs are not built but when
# configured with Nginx (when configuring it), OpenSSL has no real way of doing it.
# For this reason we are downloading an older version of OpenSSL (version 1.0.1u) where the files are correct
# and we are copying the correct file in the doc directory of the older OpenSSL version.

for element in "${OPENSSL_VERSION_LIST[@]}"; do
    if [[ "$element" == "1.0.1h" ]]; then
        break
    fi
    if [[ "$element" == "$OPENSSL_VERSION" ]]; then
        echo -e "${GREEN}[+][+][+][+] FIXING OPENSSL [+][+][+][+]${NC}"
        cp -rf "openssl-$DEFAULT_OPENSSL_VERSION/doc/crypto" "openssl-$OPENSSL_VERSION/doc"
        cp -rf "openssl-$DEFAULT_OPENSSL_VERSION/doc/ssl" "openssl-$OPENSSL_VERSION/doc"
        cp -rf "openssl-$DEFAULT_OPENSSL_VERSION/doc/apps" "openssl-$OPENSSL_VERSION/doc"
    fi
done

echo -e "${GREEN}[+][+][+][+] DOWNLOADING NGINX [+][+][+][+]${NC}"
sudo apt-get update
sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev
wget http://nginx.org/download/nginx-1.9.0.tar.gz
tar -zxvf nginx-1.9.0.tar.gz
rm nginx-1.9.0.tar.gz
cd nginx-1.9.0

echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX [+][+][+][+]${NC}"
./configure --with-http_ssl_module --with-http_fastcgi_module --with-openssl=$openssldir/openssl-$OPENSSL_VERSION --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx --with-cc-opt="-Wno-error"
make
sudo make install
cd ..

echo -e "${GREEN}[+][+][+][+] ADDING PHP SCRIPT TO NGINX [+][+][+][+]${NC}"
sudo cp -f scripts/reflection.php /usr/local/nginx/html

echo -e "${GREEN}[+][+][+][+] CREATING AN ALIAS [+][+][+][+]${NC}"
sudo mv nginx /usr/bin

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE [+][+][+][+]${NC}"
sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx/conf/cert.key -out /usr/local/nginx/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] COPY THE SERVER CONFIGURATION [+][+][+][+]${NC}"
sudo cp config.conf /usr/local/nginx/conf/nginx.conf
