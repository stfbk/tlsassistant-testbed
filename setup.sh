#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

download_openssl () {
    echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL VERSION $1 [+][+][+][+]${NC}"
    wget --no-check-certificate https://www.openssl.org/source/openssl-$1.tar.gz
    tar -zxf openssl-$1.tar.gz
    rm openssl-$1.tar.gz
}

download_nginx (){
    echo -e "${GREEN}[+][+][+][+] DOWNLOADING NGINX VERSION $1[+][+][+][+]${NC}"
    wget http://nginx.org/download/nginx-$1.tar.gz
    tar -zxvf nginx-$1.tar.gz
    rm nginx-$1.tar.gz
}

configuring_openssl () {
    echo -e "${RED}[+][+][+][+] REMOVING OPENSSL FROM YOUR SYSTEM [+][+][+][+]${NC}"
    sudo apt-get remove openssl #! might need purge, DO NOT use --auto-remove for any reason in the world
    cd openssl-0.9.8
    echo -e "${GREEN}[+][+][+][+] CONFIGURING AND INSTALLING OPENSSL VERSION $1 [+][+][+][+]${NC}"
    ./config no-asm zlib --openssldir=/usr
    sudo make
    sudo make install_sw #! here we can install_sw because the config is not done by nginx
}

configuring_nginx () {
    echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX WITH OPENSSL VERSION $2 [+][+][+][+]${NC}"
    ./configure --with-http_ssl_module --with-http_spdy_module --with-openssl="$1/openssl-$2" --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx-$2 --with-cc-opt="-Wno-error"
    sudo make
    sudo make install
}

configuring_apache () {
    echo -e "${GREEN}[+][+][+][+] INSTALLING APACHE2 [+][+][+][+]${NC}"
    sudo apt update
    sudo apt -y install apache2
    echo -e "${GREEN}[+][+][+][+] CONFIGURING APACHE2 [+][+][+][+]${NC}"
    sudo a2enmod ssl
    generating_apache_keys
    copy_apache_configuration
    sudo a2ensite default-ssl
    echo -e "${GREEN}[+][+][+][+] RESTARTING THE APACHE SERVER [+][+][+][+]${NC}"
    sudo systemctl restart apache2
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

generate_certificate () {
    echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR NGINX WITH OPENSSL VERSION $1[+][+][+][+]${NC}"
    sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-$1/conf/cert.key -out /usr/local/nginx-$1/conf/cert.pem -days 365
}

copy_configuration () {
    echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
    sudo cp config.conf /usr/local/nginx-$1/conf/nginx.conf
    
}

OPENSSL_VERSION_LIST=(
    "0.9.8" #? 0.9.8 might not need to have the .pod files fixed (?) crazy how bad openssl is
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
    "1.1.1"
)

echo "Start setup of the virtual machine..."

#! SETUP

sudo apt-get update
yes | sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev

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

openssldir_v_u=$(pwd)
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
        if [[ "$element" == "1.0.1h" ]]; then
            openssldir_v_user=$(pwd)
            download_openssl $OPENSSL_VERSION
            break
        fi
        if [ "$element" == "$OPENSSL_VERSION" ]; then
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

#! DOWNLOADING NGINX

download_nginx 1.9.0
cd nginx-1.9.0

#! CONFIGURING NGINX

configuring_nginx $openssldir_v_u $DEFAULT_OPENSSL_VERSION

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    if [ "$OPENSSL_VERSION" == "1.1.1" ]; then
        cd ..
        download_nginx 1.15.0
        cd nginx-1.15.0
    fi
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

#! GENERATING THE CERTIFICATE

generate_certificate $DEFAULT_OPENSSL_VERSION

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    generate_certificate $OPENSSL_VERSION
fi

#! COPY THE CONFIGURATION TO NGINX

copy_configuration $DEFAULT_OPENSSL_VERSION

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    copy_configuration $OPENSSL_VERSION
fi

#! CHECKING IF EVERYTHING IS OK

if [ -d "/usr/local/nginx-$DEFAULT_OPENSSL_VERSION" ] && [ -d "/usr/local/nginx-$OPENSSL_VERSION" ]; then
    echo -e "${GREEN}[+][+][+][+] THE CONFIGURATION IS DONE [+][+][+][+]${NC}"
    elif [ -d "/usr/local/nginx-$DEFAULT_OPENSSL_VERSION "]; then
    echo -e "${YELLOW}[+][+][+][+] ONLY THE DEFAULT WEBSERVER WAS CONFIGURED [+][+][+][+]${NC}"
else
    echo -e "${RED}[+][+][+][+] CONFIGURATION FAILED [+][+][+][+]${NC}"
fi


