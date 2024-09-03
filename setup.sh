#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

download_openssl () {
    echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL VERSION $1 [+][+][+][+]${NC}"
    wget --no-check-certificate https://www.openssl.org/source/openssl-$1.tar.gz
    tar -zxf openssl-$1.tar.gz
    rm openssl-$1.tar.gz
}

configuring_nginx () {
    echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX WITH OPENSSL VERSION $2 [+][+][+][+]${NC}"
    ./configure --with-http_ssl_module --with-http_spdy_module --with-openssl="$1/openssl-$2" --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx-$2 --with-cc-opt="-Wno-error"
    sudo make
    sudo make install
}

add_php_script () {
    echo -e "${GREEN}[+][+][+][+] ADDING PHP SCRIPT TO NGINX [+][+][+][+]${NC}"
    sudo cp -f scripts/reflection.php /usr/local/nginx-$1/html
}

creating_alias () {
    echo -e "${GREEN}[+][+][+][+] CREATING AN ALIAS FOR $1 [+][+][+][+]${NC}"
    echo -e "#!/bin/bash\nsudo /usr/local/nginx-$1/sbin/nginx" > nginx-$1
    chmod 777 nginx-$1
    sudo mv nginx-$1 /usr/bin
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

#! INSTALLING PHP

echo -e "${GREEN}[+][+][+][+] INSTALLING PHP [+][+][+][+]${NC}"
yes | sudo apt-get install php-fpm

#! SETTING UP THE DEFAULT OPENSSL VERSION

DEFAULT_OPENSSL_VERSION="1.0.1u"

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

openssldir_v_u=$(pwd)A
openssldir_v_user=""

#! DOWNLOADING OPENSSL

download_openssl $DEFAULT_OPENSSL_VERSION

# In older versions of OpenSSL (from 1.0.1 to 1.0.1g) the pod files present some syntax errors.
# Normally we would run the sudo make install_sw so that the manuals and docs are not built but when
# configured with Nginx (when configuring it), OpenSSL has no real way of doing it.
# For this reason we are downloading a newer version of OpenSSL (version 1.0.1u) where the files are correct
# and we are copying the correct files in the doc directory of the older OpenSSL version.

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    for element in "${OPENSSL_VERSION_LIST[@]}"; do
        if [ "$element" == "$OPENSSL_VERSION" ]; then
            if [[ "$element" == "1.0.1h" ]]; then
                openssldir_v_user=$(pwd)
                download_openssl $OPENSSL_VERSION
                break
            fi
            
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

#! DOWNLOADING NGINX (only one version at the time for the moment)

echo -e "${GREEN}[+][+][+][+] DOWNLOADING NGINX [+][+][+][+]${NC}"
sudo apt-get update
yes | sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev
wget http://nginx.org/download/nginx-1.9.0.tar.gz
tar -zxvf nginx-1.9.0.tar.gz
rm nginx-1.9.0.tar.gz
cd nginx-1.9.0

#! CONFIGURING NGINX

configuring_nginx $openssldir_v_u $DEFAULT_OPENSSL_VERSION

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    configuring_nginx $openssldir_v_user $OPENSSL_VERSION
fi

cd ..

#! ADDING PHP SCRIPT TO NGINX CONFIGURATION

add_php_script $DEFAULT_OPENSSL_VERSION

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    add_php_script $OPENSSL_VERSION
fi

#! CREATING AN ALIAS FOR THE NGINX SERVER

creating_alias $DEFAULT_OPENSSL_VERSION

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    creating_alias $OPENSSL_VERSION
fi

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE [+][+][+][+]${NC}"
sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-$DEFAULT_OPENSSL_VERSION/conf/cert.key -out /usr/local/nginx-$DEFAULT_OPENSSL_VERSION/conf/cert.pem -days 365

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE [+][+][+][+]${NC}"
    sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-$OPENSSL_VERSION/conf/cert.key -out /usr/local/nginx-$OPENSSL_VERSION/conf/cert.pem -days 365
fi

echo -e "${GREEN}[+][+][+][+] COPY THE SERVER CONFIGURATION [+][+][+][+]${NC}"
sudo cp config.conf /usr/local/nginx-$DEFAULT_OPENSSL_VERSION/conf/nginx.conf

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    echo -e "${GREEN}[+][+][+][+] COPY THE SERVER CONFIGURATION [+][+][+][+]${NC}"
    sudo cp config.conf /usr/local/nginx-$OPENSSL_VERSION/conf/nginx.conf
fi

echo -e "${GREEN}[+][+][+][+] THE CONFIGURATION IS DONE [+][+][+][+]${NC}"
