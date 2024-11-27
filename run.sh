#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+][+][+][+] STARTING THE WEBSERVER WITH NGINX WITH OPENSSL VERSION 1.0.1u [+][+][+][+]${NC}"
/usr/local/nginx-1.0.1u/sbin/nginx

echo -e "${GREEN}[+][+][+][+] STARTING THE WEBSERVER WITH NGINX WITH OPENSSL VERSION 1.0.1a [+][+][+][+]${NC}"
/usr/local/nginx-1.0.1a/sbin/nginx

echo -e "${GREEN}[+][+][+][+] STARTING THE WEBSERVER WITH NGINX WITH OPENSSL VERSION 1.0.2l [+][+][+][+]${NC}"
/usr/local/nginx-1.0.2l/sbin/nginx

echo -e "${GREEN}[+][+][+][+] STARTING THE APACHE WEBSERVER [+][+][+][+]${NC}"
/usr/local/apache2/bin/apachectl start

sleep infinity