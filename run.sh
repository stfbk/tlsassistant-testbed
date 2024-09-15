#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+][+][+][+] Start setup of the virtual machine... [+][+][+][+]${NC}"

apt-get update
apt-get -y install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev git docker.io
apt install -y aha html2text libxml2-utils pandoc dos2unix python-pip libexpat1-dev geany
pip install --pre tlslite-ng


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
make
make install

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR NGINX WITH OPENSSL VERSION 1.0.1u [+][+][+][+]${NC}"
openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-1.0.1u/conf/cert.key -out /usr/local/nginx-1.0.1u/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
cp ../configs/config-1.0.1u.conf /usr/local/nginx-1.0.1u/conf/nginx.conf

echo -e "${GREEN}[+][+][+][+] STARTING THE WEBSERVER WITH NGINX WITH OPENSSL VERSION 1.0.1u [+][+][+][+]${NC}"
/usr/local/nginx-1.0.1u/sbin/nginx

# full configuration of Nginx 1.9.0 WebServer with OpenSSL version 1.0.1a

echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
wget --no-check-certificate https://www.openssl.org/source/openssl-1.0.1a.tar.gz
tar -zxf openssl-1.0.1a.tar.gz
rm openssl-1.0.1a.tar.gz

echo -e "${GREEN}[+][+][+][+] FIXING OPENSSL DOCS [+][+][+][+]${NC}"
cp -rf ../doc openssl-1.0.1a

echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX WITH OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
./configure --with-http_ssl_module --with-openssl="openssl-1.0.1a" --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4 enable-ssl2' --with-http_gzip_static_module --prefix=/usr/local/nginx-1.0.1a --with-cc-opt="-Wno-error"
make
make install

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR NGINX WITH OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-1.0.1a/conf/cert.key -out /usr/local/nginx-1.0.1a/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
cp ../configs/config-1.0.1a.conf /usr/local/nginx-1.0.1a/conf/nginx.conf

echo -e "${GREEN}[+][+][+][+] STARTING THE WEBSERVER WITH NGINX WITH OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
/usr/local/nginx-1.0.1a/sbin/nginx

# full configuration of OpenSSL S_Server with OpenSSL version 1.0.2-patched by DamnVulnerableOpenSSL (https://github.com/tls-attacker/DamnVulnerableOpenSSL.git)

echo -e "${GREEN}[+][+][+][+] CLONING DamnVulnerableOpenSSL FROM GitHub [+][+][+][+]${NC}"
git clone https://github.com/tls-attacker/DamnVulnerableOpenSSL.git
cd DamnVulnerableOpenSSL

echo -e "${GREEN}[+][+][+][+] FIXING INSTALLATION FILE FOR PATCH [+][+][+][+]${NC}"
sed -i '/.\/config/d' ./install.sh
sed -i '/make -j4/d' ./install.sh
sed -i '/cd openssl-1.0.2l/d' ./install.sh

./install.sh
cd ..

echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX WITH OPENSSL VERSION 1.0.2l patched [+][+][+][+]${NC}"
./configure --with-http_ssl_module --with-openssl="DamnVulnerableOpenSSL/openssl-1.0.2l" --prefix=/usr/local/nginx-1.0.2l --with-cc-opt="-Wno-error"
make
make install

echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
cp ../configs/config-1.0.2l.conf /usr/local/nginx-1.0.2l/conf/nginx.conf

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR NGINX WITH OPENSSL VERSION 1.0.2l [+][+][+][+]${NC}"
openssl req -x509 -nodes -subj "/CN=fbk.eu" -newkey rsa:4096 -keyout /usr/local/nginx-1.0.2l/conf/cert.key -out /usr/local/nginx-1.0.2l/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] STARTING THE WEBSERVER WITH NGINX WITH OPENSSL VERSION 1.0.2l [+][+][+][+]${NC}"
/usr/local/nginx-1.0.2l/sbin/nginx
cd ..

#echo -e "${GREEN}[+][+][+][+] BUILDING DOCKER FOR DamnVulnerableOpenSSL [+][+][+][+]${NC}"
#docker build -t damnvulnerableopenssl .

#echo -e "${GREEN}[+][+][+][+] RUNNING DamnVulnerableOpenSSL OPENSSL SERVER [+][+][+][+]${NC}"
#docker run -p 9006:9006 damnvulnerableopenssl &

# full configuration of Apache Webserver with apr-1.6.5, apr-util-1.6.1, httpd 2.4.37 and OpenSSL version 1.0.2-stable

mkdir apache && cd apache
echo -e "${GREEN}[+][+][+][+] DOWNLOADING OPENSSL VERSION 1.0.2 [+][+][+][+]${NC}"
git clone --single-branch -b OpenSSL_1_0_2-stable https://github.com/openssl/openssl.git
cd openssl
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl enable-weak-ssl-ciphers enable-deprecated enable-rc4 enable-ssl2 enable-ssl3 enable-ssl3-method enable-comp enable-zlib-dynamic -Wl,-rpath=/usr/local/ssl/lib
make depend
make
make install_sw
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
make install
cd ..

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE FOR APACHE WITH OPENSSL VERSION 1.0.2 [+][+][+][+]${NC}"
mkdir certificates && cd certificates
openssl genrsa -out dummy.com.key 4096
openssl req -new -key dummy.com.key -out dummy.com.csr -sha512 -subj '/C=IT/ST=Trento/L=Trento/O=FBK/OU=S&T/CN=www.dummy.com'
openssl x509 -req -days 365 -in dummy.com.csr -signkey dummy.com.key -out dummy.com.crt -sha512
cd ..
cp -r certificates/ /usr/local/apache2/

echo -e "${GREEN}[+][+][+][+] COPYING THE SERVER CONFIGURATION [+][+][+][+]${NC}"
cp ../configs/httpd-ssl-apache.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
cp ../configs/httpd-apache.conf /usr/local/apache2/conf/httpd.conf
rm /usr/local/apache2/htdocs/index.html 2>/dev/null
touch /usr/local/apache2/htdocs/index.html
echo "<html><head><title>Experiment</title></head><hr><h1>Experimental dummy page</h1><p>Dummy text, from dummy developers, for dummy code. ;) </p><!-- DummyDevs ;) --></body></html>" | tee -a /usr/local/apache2/htdocs/index.html > /dev/null
cd ..

echo -e "${GREEN}[+][+][+][+] STARTING THE APACHE WEBSERVER [+][+][+][+]${NC}"
/usr/local/apache2/bin/apachectl -k start

# gn
sleep infinity