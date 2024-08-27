GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Start setup of the virtual machine..."

echo -e "${GREEN}[+][+][+][+] DOWNGRADING OPENSSL [+][+][+][+]${NC}"
wget --no-check-certificate https://www.openssl.org/source/openssl-1.0.2u.tar.gz
openssldir=$(pwd)
tar -zxf openssl-1.0.2u.tar.gz
