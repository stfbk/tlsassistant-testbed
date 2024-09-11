#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

MAINDIR=$(pwd)
OUTPUT="dump.log"
DEFAULT_OPENSSL_VERSION="1.0.1u"
OPENSSL_VERSION_LIST=(
    "0.9.8"
    "1.0.1" "1.0.1a" "1.0.1b" "1.0.1c" "1.0.1d" "1.0.1e" "1.0.1f"
    "1.0.1g" "1.0.1h" "1.0.1i" "1.0.1j" "1.0.1k" "1.0.1l" "1.0.1m"
    "1.0.1n" "1.0.1o" "1.0.1p" "1.0.1q" "1.0.1r" "1.0.1s" "1.0.1t"
    "1.0.1u" "1.1.1"
)

show_help() {
    echo "Usage: sudo ./setup.sh [OPTIONS] [OPENSSL_VERSION]"
    echo
    echo "Options:"
    echo "  -v, --verbose   Show detailed output of all commands."
    echo "  -h, --help      Show this help message."
    echo
    echo "Examples:"
    echo "  sudo ./setup.sh 1.0.1h       Install and configure OpenSSL version 1.0.1h."
    echo "  sudo ./setup.sh --verbose    Run script with detailed output."
}

download_openssl () {
    echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL VERSION $1 [+][+][+][+]${NC}"
    wget --no-check-certificate https://www.openssl.org/source/openssl-$1.tar.gz &> $OUTPUT
    tar -zxf openssl-$1.tar.gz &> $OUTPUT
    rm openssl-$1.tar.gz &> $OUTPUT
}

download_nginx () {
    echo -e "${GREEN}[+][+][+][+] DOWNLOADING NGINX VERSION $1 [+][+][+][+]${NC}"
    wget http://nginx.org/download/nginx-$1.tar.gz &> $OUTPUT
    tar -zxvf nginx-$1.tar.gz &> $OUTPUT
    rm nginx-$1.tar.gz &> $OUTPUT
}

configuring_openssl () {
    echo -e "${RED}[+][+][+][+] REMOVING OPENSSL FROM YOUR SYSTEM [+][+][+][+]${NC}"
    sudo apt-get -y remove openssl &> $OUTPUT
    cd openssl-$1
    echo -e "${GREEN}[+][+][+][+] CONFIGURING AND INSTALLING OPENSSL VERSION $1 [+][+][+][+]${NC}"
    ./config no-asm zlib --openssldir=/usr &> $OUTPUT
    sudo make &> $OUTPUT
    sudo make install_sw &> $OUTPUT
}

configuring_nginx () {
    echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX WITH OPENSSL VERSION $2 [+][+][+][+]${NC}"
    ./configure --with-http_ssl_module --with-http_spdy_module --with-openssl="$1/openssl-$2" --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx-$2 --with-cc-opt="-Wno-error" &> $OUTPUT
    sudo make &> $OUTPUT
    sudo make install &> $OUTPUT
}

configuring_apache () {
    echo -e "${GREEN}[+][+][+][+] INSTALLING AND CONFIGURING APACHE2 [+][+][+][+]${NC}"
    sudo apt update &> $OUTPUT
    sudo apt -y install apache2 &> $OUTPUT
    sudo a2enmod ssl &> $OUTPUT
    sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt &> $OUTPUT
    sudo cp -f default-ssl.conf /etc/apache2/sites-available/ &> $OUTPUT
    sudo a2ensite default-ssl &> $OUTPUT
    sudo systemctl restart apache2 &> $OUTPUT
}

add_php_script () {
    echo -e "${GREEN}[+][+][+][+] ADDING PHP SCRIPT TO NGINX [+][+][+][+]${NC}"
    sudo cp -f scripts/reflection.php /usr/local/nginx-$1/html &> $OUTPUT
}

creating_alias () {
    echo -e "${GREEN}[+][+][+][+] CREATING AN ALIAS FOR $1 [+][+][+][+]${NC}"
    echo -e "#!/bin/bash\nsudo /usr/local/nginx-$1/sbin/nginx" > nginx-$1
    chmod 777 nginx-$1 &> $OUTPUT
    sudo mv nginx-$1 /usr/bin &> $OUTPUT
}

generate_certificate () {
    echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR NGINX WITH OPENSSL VERSION $1 [+][+][+][+]${NC}"
    sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-$1/conf/cert.key -out /usr/local/nginx-$1/conf/cert.pem -days 365 &> $OUTPUT
}

copy_configuration () {
    echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
    sudo cp config.conf /usr/local/nginx-$1/conf/nginx.conf &> $OUTPUT
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose|v)
            OUTPUT="/dev/stdout"
            shift
        ;;
        -h|--help|help)
            show_help
            exit 0
        ;;
        *)
            OPENSSL_VERSION="$1"
            shift
        ;;
    esac
done

OPENSSL_VERSION=${OPENSSL_VERSION:-$DEFAULT_OPENSSL_VERSION}

echo "Start setup of the virtual machine..."

sudo apt-get update &> $OUTPUT
yes | sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev php-fpm &> $OUTPUT

download_openssl $DEFAULT_OPENSSL_VERSION
[ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ] && download_openssl $OPENSSL_VERSION

# In older versions of OpenSSL (from 1.0.1 to 1.0.1g) the pod files present some syntax errors.
# Normally we would run the sudo make install_sw so that the manuals and docs are not built but when
# configured with Nginx (when configuring it), OpenSSL has no real way of doing it.
# For this reason we are downloading a newer version of OpenSSL (version 1.0.1u) where the files are correct
# and we are copying the correct files in the doc directory of the older OpenSSL version.

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ] && [[ "$OPENSSL_VERSION" =~ ^1\.0\.1[a-u]$ ]]; then
    echo -e "${GREEN}[+][+][+][+] FIXING OPENSSL DOCS [+][+][+][+]${NC}"
    cp -rf openssl-$DEFAULT_OPENSSL_VERSION/doc openssl-$OPENSSL_VERSION &> $OUTPUT
fi

download_nginx 1.9.0
cd nginx-1.9.0
configuring_nginx $MAINDIR $DEFAULT_OPENSSL_VERSION

if [ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ]; then
    if [ "$OPENSSL_VERSION" == "1.1.1" ]; then
        cd ..
        download_nginx 1.15.0
        cd nginx-1.15.0
        elif [ "$OPENSSL_VERSION" == "0.9.8" ]; then
        cd ..
        configuring_openssl 0.9.8
        cd ..
        configuring_apache
    fi
    
    [ "$OPENSSL_VERSION" == "0.9.8" ] || configuring_nginx $MAINDIR $OPENSSL_VERSION
fi

cd ..

add_php_script $DEFAULT_OPENSSL_VERSION
[ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ] && [ "$OPENSSL_VERSION" != "0.9.8" ] && add_php_script $OPENSSL_VERSION

creating_alias $DEFAULT_OPENSSL_VERSION
[ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ] && [ "$OPENSSL_VERSION" != "0.9.8" ] && creating_alias $OPENSSL_VERSION

generate_certificate $DEFAULT_OPENSSL_VERSION
[ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ] && [ "$OPENSSL_VERSION" != "0.9.8" ] && generate_certificate $OPENSSL_VERSION

copy_configuration $DEFAULT_OPENSSL_VERSION
[ "$OPENSSL_VERSION" != "$DEFAULT_OPENSSL_VERSION" ] && [ "$OPENSSL_VERSION" != "0.9.8" ] && copy_configuration $OPENSSL_VERSION

if [ -d "/usr/local/nginx-$DEFAULT_OPENSSL_VERSION" ] && [ -d "/usr/local/nginx-$OPENSSL_VERSION" ]; then
    echo -e "${GREEN}[+][+][+][+] THE CONFIGURATION IS DONE [+][+][+][+]${NC}"
    elif [ -d "/usr/local/nginx-$DEFAULT_OPENSSL_VERSION" ]; then
    echo -e "${YELLOW}[+][+][+][+] ONLY THE DEFAULT WEBSERVER WAS CONFIGURED [+][+][+][+]${NC}"
else
    echo -e "${RED}[+][+][+][+] CONFIGURATION FAILED [+][+][+][+]${NC}"
fi
