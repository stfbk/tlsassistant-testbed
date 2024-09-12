#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+][+][+][+] Start setup of the virtual machine... [+][+][+][+]${NC}"

sudo apt-get update
sudo apt-get -y install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev git docker.io 
sudo apt install -y aha html2text libxml2-utils pandoc dos2unix python-pip libexpat1-dev geany 
sudo pip install --pre tlslite-ng


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

# full configuration of Apache Webserver with apr-1.6.5, apr-util-1.6.1, httpd 2.4.37 and OpenSSL version 1.0.2-stable
mkdir apache && cd apache
echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL VERSION 1.0.2 [+][+][+][+]${NC}"
git clone -b OpenSSL_1_0_2-stable https://github.com/openssl/openssl.git
cd openssl
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl enable-weak-ssl-ciphers enable-deprecated enable-rc4 enable-ssl2 enable-ssl3 enable-ssl3-method enable-comp enable-zlib-dynamic -Wl,-rpath=/usr/local/ssl/lib
make depend
make 
sudo make install 
cd ..

echo -e "${GREEN}[+][+][+][+] DOWNLOADING APACHE HTTPD, APR & APR-UTIL [+][+][+][+]${NC}"

tar xvjf ../dependencies/httpd-2.4.37.tar.bz2

tar xvf ../dependencies/apr-1.6.5.tar.gz
mv apr-1.6.5 httpd-2.4.37/srclib/apr

tar xvf ../dependencies/apr-util-1.6.1.tar.gz
mv apr-util-1.6.1 httpd-2.4.37/srclib/apr-util

cd httpd-2.4.37
./configure --with-included-apr --enable-ssl --with-ssl=/usr/local/ssl --enable-deflate --enable-mods-static=ssl --enable-mods-shared=deflate
make
sudo make install
cd ..

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR APACHE WITH OPENSSL VERSION 1.0.2 [+][+][+][+]${NC}"
mkdir certificates && cd certificates
sudo openssl genrsa -out dummy.com.key 4096
sudo openssl req -new -key dummy.com.key -out dummy.com.csr -sha512 -subj '/C=IT/ST=Trento/L=Trento/O=FBK/OU=S&T/CN=www.dummy.com'
sudo openssl x509 -req -days 365 -in dummy.com.csr -signkey dummy.com.key -out dummy.com.crt -sha512
cd .. 
cp -r certificates/ /usr/local/apache2/


echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
sudo cp ../configs/httpd-ssl-apache.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
sudo cp ../configs/httpd-apache.conf /usr/local/apache2/conf/httpd.conf
sudo rm /usr/local/apache2/htdocs/index.html 2>/dev/null
sudo touch /usr/local/apache2/htdocs/index.html
echo "<html><head><title>Experiment</title></head><hr><h1>Experimental dummy page</h1><p>Dummy text, from dummy developers, for dummy code. ;) </p><!-- DummyDevs ;) --></body></html>" | sudo tee -a /usr/local/apache2/htdocs/index.html > /dev/null
cd ..

sudo /usr/local/apache2/bin/apachectl -k start

# full configuration of OpenSSL S_Server with OpenSSL version 1.0.2-patched by DamnVulnerableOpenSSL (https://github.com/tls-attacker/DamnVulnerableOpenSSL.git)

echo -e "${GREEN}[+][+][+][+] CLONING DamnVulnerableOpenSSL FROM GitHub [+][+][+][+]${NC}"
git clone https://github.com/tls-attacker/DamnVulnerableOpenSSL.git
cd DamnVulnerableOpenSSL

echo -e "${GREEN}[+][+][+][+] BUILDING DOCKER FOR DamnVulnerableOpenSSL [+][+][+][+]${NC}"
sudo docker build -t damnvulnerableopenssl .

echo -e "${GREEN}[+][+][+][+] RUNNING DamnVulnerableOpenSSL OPENSSL SERVER [+][+][+][+]${NC}"
sudo docker run -p 9006:9006 damnvulnerableopenssl &


AH00526: Syntax error on line 144 of /usr/local/apache2/conf/extra/httpd-ssl.conf:
SSLCertificateFile: file '/usr/local/apache2/certificates/dummy.com.crt' does not exist