#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

download_openssl () {
    echo -e "${GREEN}[+][+][+][+] INSTALLING OPENSSL [+][+][+][+]${NC}"
    wget --no-check-certificate https://www.openssl.org/source/openssl-$1.tar.gz
    tar -zxf openssl-$1.tar.gz
    rm openssl-$1.tar.gz
}

configuring_nginx () {
    ./configure --with-http_ssl_module --with-openssl="$1/openssl-$2" --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx_$2 --with-cc-opt="-Wno-error"
    sudo make
    sudo make install
}

creating_alias () {
    echo -e "#!/bin/bash\nsudo /usr/local/nginx_$1/sbin/nginx" > nginx_$1
    chmod 777 nginx_$1
    sudo mv nginx_$1 /usr/bin
}


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

if [ -z "$1" ]; then
    OPENSSL_VERSION=$DEFAULT_OPENSSL_VERSION
else
    for version in "${OPENSSL_VERSION_LIST[@]}"; do
        if [ "$1" == "$version" ]; then
            OPENSSL_VERSION="$1"
            break
        fi
    done
fi

openssldir_v_u=$(pwd)
openssldir_v_user=""

echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL $DEFAULT_OPENSSL_VERSION [+][+][+][+]${NC}"
download_openssl $DEFAULT_OPENSSL_VERSION

# In older versions of OpenSSL (from 1.0.1 to 1.0.1g) the pod files present some syntax errors.
# Normally we would run the sudo make install_sw so that the manuals and docs are not built but when
# configured with Nginx (when configuring it), OpenSSL has no real way of doing it.
# For this reason we are downloading a newer version of OpenSSL (version 1.0.1u) where the files are correct
# and we are copying the correct files in the doc directory of the older OpenSSL version.

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    for element in "${OPENSSL_VERSION_LIST[@]}"; do
        if [ "$element" == "$OPENSSL_VERSION" ]; then
            echo -e "${GREEN}[+][+][+][+] DOWNGRADING OPENSSL $OPENSSL_VERSION [+][+][+][+]${NC}"
            openssldir_v_user=$(pwd)
            download_openssl $OPENSSL_VERSION
            echo -e "${GREEN}[+][+][+][+] FIXING OPENSSL [+][+][+][+]${NC}"
            cp -rf "openssl-$DEFAULT_OPENSSL_VERSION/doc/crypto" "openssl-$OPENSSL_VERSION/doc"
            cp -rf "openssl-$DEFAULT_OPENSSL_VERSION/doc/ssl" "openssl-$OPENSSL_VERSION/doc"
            cp -rf "openssl-$DEFAULT_OPENSSL_VERSION/doc/apps" "openssl-$OPENSSL_VERSION/doc"
            break
        fi
    done
fi

echo -e "${GREEN}[+][+][+][+] DOWNLOADING NGINX [+][+][+][+]${NC}"
sudo apt-get update
sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev
wget http://nginx.org/download/nginx-1.9.0.tar.gz
tar -zxvf nginx-1.9.0.tar.gz
rm nginx-1.9.0.tar.gz
cd nginx-1.9.0

echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX $DEFAULT_OPENSSL_VERSION [+][+][+][+]${NC}"
configuring_nginx $openssldir_v_u $DEFAULT_OPENSSL_VERSION

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX $OPENSSL_VERSION [+][+][+][+]${NC}"
    configuring_nginx $openssldir_v_user $OPENSSL_VERSION
fi

cd ..

echo -e "${GREEN}[+][+][+][+] ADDING PHP SCRIPT TO NGINX [+][+][+][+]${NC}"
sudo cp -f scripts/reflection.php /usr/local/nginx/html

echo -e "${GREEN}[+][+][+][+] CREATING AN ALIAS [+][+][+][+]${NC}"
sudo mv nginx /usr/bin

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE [+][+][+][+]${NC}"
sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx/conf/cert.key -out /usr/local/nginx/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] COPY THE SERVER CONFIGURATION [+][+][+][+]${NC}"
sudo cp config.conf /usr/local/nginx/conf/nginx.conf
