#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+][+][+][+] Start setup of the virtual machine... [+][+][+][+]${NC}"

sudo apt-get update
sudo apt-get -y install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev git docker.io

echo -e "${GREEN}[+][+][+][+] DOWNLOADING NGINX VERSION 1.9.0 [+][+][+][+]${NC}"
wget http://nginx.org/download/nginx-1.9.0.tar.gz
tar -zxvf nginx-1.9.0.tar.gz
rm nginx-1.9.0.tar.gz
cd nginx-1.9.0

# full configuration of Nginx 1.9.0 WebServer with OpenSSL version 1.0.1u

echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL VERSION 1.0.1u [+][+][+][+]${NC}"
wget --no-check-certificate https://www.openssl.org/source/openssl-1.0.1u.tar.gz
tar -zxf openssl-1.0.1u.tar.gz
rm openssl-1.0.1u.tar.gz

echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX WITH OPENSSL VERSION 1.0.1u [+][+][+][+]${NC}"
./configure --with-http_ssl_module --with-openssl="openssl-1.0.1u" --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx-1.0.1u --with-cc-opt="-Wno-error"
sudo make
sudo make install

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR NGINX WITH OPENSSL VERSION 1.0.1u [+][+][+][+]${NC}"
sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-1.0.1u/conf/cert.key -out /usr/local/nginx-1.0.1u/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
sudo cp ../configs/config-1.0.1u.conf /usr/local/nginx-1.0.1u/conf/nginx.conf

echo -e "${GREEN}[+][+][+][+] STARTING THE WEBSERVER WITH NGINX WITH OPENSSL VERSION 1.0.1u [+][+][+][+]${NC}"
sudo /usr/local/nginx-1.0.1u/sbin/nginx

# full configuration of Nginx 1.9.0 WebServer with OpenSSL version 1.0.1a

echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
wget --no-check-certificate https://www.openssl.org/source/openssl-1.0.1a.tar.gz
tar -zxf openssl-1.0.1a.tar.gz
rm openssl-1.0.1a.tar.gz

echo -e "${GREEN}[+][+][+][+] FIXING OPENSSL DOCS [+][+][+][+]${NC}"
sudo cp -rf ../doc openssl-1.0.1a

echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX WITH OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
./configure --with-http_ssl_module --with-openssl="openssl-1.0.1a" --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx-1.0.1a --with-cc-opt="-Wno-error"
sudo make
sudo make install

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR NGINX WITH OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
sudo openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-1.0.1a/conf/cert.key -out /usr/local/nginx-1.0.1a/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
sudo cp ../configs/config-1.0.1a.conf /usr/local/nginx-1.0.1a/conf/nginx.conf

echo -e "${GREEN}[+][+][+][+] STARTING THE WEBSERVER WITH NGINX WITH OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
sudo /usr/local/nginx-1.0.1a/sbin/nginx
cd ..

# full configuration of OpenSSL S_Server with OpenSSL version 1.0.2-patched by DamnVulnerableOpenSSL (https://github.com/tls-attacker/DamnVulnerableOpenSSL.git)

echo -e "${GREEN}[+][+][+][+] CLONING DamnVulnerableOpenSSL FROM GitHub [+][+][+][+]${NC}"
git clone https://github.com/tls-attacker/DamnVulnerableOpenSSL.git
cd DamnVulnerableOpenSSL

echo -e "${GREEN}[+][+][+][+] BUILDING DOCKER FOR DamnVulnerableOpenSSL [+][+][+][+]${NC}"
sudo docker build -t damnvulnerableopenssl .

echo -e "${GREEN}[+][+][+][+] RUNNING DamnVulnerableOpenSSL OPENSSL SERVER [+][+][+][+]${NC}"
sudo docker run -p 9006:9006 damnvulnerableopenssl