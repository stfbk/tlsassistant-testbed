GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Start setup of the virtual machine..."

echo -e "${GREEN}[+][+][+][+] DOWNGRADING OPENSSL [+][+][+][+]${NC}"
wget --no-check-certificate https://www.openssl.org/source/openssl-1.0.2u.tar.gz
openssldir=$(pwd)
tar -zxf openssl-1.0.2u.tar.gz

echo -e "${GREEN}[+][+][+][+] DOWNLOADING NGINX [+][+][+][+]${NC}"
sudo apt-get update
sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev
wget http://nginx.org/download/nginx-1.9.0.tar.gz
tar -zxvf nginx-1.9.0.tar.gz
cd nginx-1.9.0

echo -e "${GREEN}[+][+][+][+] CONFIGURING NGINX [+][+][+][+]${NC}"
./configure --with-http_ssl_module --with-openssl=$openssldir/openssl-1.0.2u --with-openssl-opt='enable-weak-ssl-ciphers enable-rc4' --with-http_gzip_static_module --prefix=/usr/local/nginx --with-cc-opt="-Wno-error"
make
sudo make install
cd ..

echo -e "${GREEN}[+][+][+][+] CREATING AN ALIAS [+][+][+][+]${NC}"
echo "alias nginx=\"sudo /usr/local/nginx/sbin/nginx\"" | tee -a ~/.bashrc

echo -e "${GREEN}[+][+][+][+] GENERATING THE CERTIFICATE [+][+][+][+]${NC}"
sudo openssl req -x509 -nodes -newkey rsa:4096 -keyout /usr/local/nginx/conf/cert.key -out /usr/local/nginx/conf/cert.pem -days 365

echo -e "${GREEN}[+][+][+][+] COPY THE SERVER CONFIGURATION [+][+][+][+]${NC}"
sudo cp config.conf /usr/local/nginx/conf/nginx.conf
