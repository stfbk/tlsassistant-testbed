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

DEFAULT_OPENSSL_VERSION="1.0.1u"
if [ -z $1 ]; then
    OPENSSL_VERSION=$DEFAULT_OPENSSL_VERSION
else
    for version in "${OPENSSL_VERSION_LIST[@]}"; do
        if [ "$1" == "$version" ]; then
            OPENSSL_VERSION="$1"
            break
        fi
    done
fi

echo "Start setup of the virtual machine..."

echo -e "${GREEN}[+][+][+][+] DOWNGRADING OPENSSL [+][+][+][+]${NC}"
wget --no-check-certificate https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
openssldir=$(pwd)
tar -zxf openssl-$OPENSSL_VERSION.tar.gz
rm openssl-$OPENSSL_VERSION.tar.gz

for element in "${OPENSSL_VERSION_LIST[@]}"; do
    if [[ "$element" == "1.0.1h" ]]; then
        break
    fi
    
    if [[ "$element" == "$OPENSSL_VERSION" ]]; then
        echo -e "${GREEN}[+][+][+][+] FIXING OPENSSL [+][+][+][+]${NC}"
        source_dir="pod-files"
        destination_dir="openssl-$OPENSSL_VERSION/doc/ssl"
        files=("SSL_accept.pod" "SSL_clear.pod" "SSL_COMP_add_compression_method.pod" "SSL_connect.pod" "SSL_CTX_add_session.pod" "SSL_CTX_load_verify_location.pod" "SSL_CTX_set_client_CA_list.pod" "SSL_CTX_set_session_id_context.pod" "SSL_CTX_set_ssl_version.pod" "SSL_CTX_use_psk_identity_hint.pod" "SSL_do_handshake.pod" "SSL_read.pod" "SSL_session_reused.pod" "SSL_set_fd.pod" "SSL_set_session.pod" "SSL_shutdown.pod" "SSL_write.pod")
        for file in "${files[@]}"; do
            cp "${source_dir}/${file}" "${destination_dir}/${file}"
        done
        cp "${source_dir}/cms.pod" "openssl-$OPENSSL_VERSION/doc/apps/cms.pod"
        cp "${source_dir}/smime.pod" "openssl-$OPENSSL_VERSION/doc/apps/smime.pod"
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
./configure --with-http_ssl_module --with-openssl=$openssldir/openssl-$OPENSSL_VERSION --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx --with-cc-opt="-Wno-error"
make
sudo make install
cd ..

echo -e "${GREEN}[+][+][+][+] CREATING AN ALIAS [+][+][+][+]${NC}"
sudo mv nginx /usr/bin

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE [+][+][+][+]${NC}"
sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx/conf/cert.key -out /usr/local/nginx/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] COPY THE SERVER CONFIGURATION [+][+][+][+]${NC}"
sudo cp config.conf /usr/local/nginx/conf/nginx.conf
