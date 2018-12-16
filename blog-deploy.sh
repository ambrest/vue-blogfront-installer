#!/bin/bash

# to run: bash <(curl -s0 https://get-blog.ambrest.io)

#Colors!
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTBLUE='\033[1;34m'
PURPLE='\033[1;35m'

NC='\033[0m'

#Ask questions

NUMBER=$RANDOM

echo -e "\n\nWelcome to the ${LIGHTBLUE}Ambrest Designs LLC${NC} ${PURPLE}vue-blogfront${NC} installer!"
echo -e "Copyright 2018 Ambrest Designs LLC <https://ambrest.io>\n"

echo -e "This installer is provided ${RED}WITHOUT WARRANTY${NC}.\n\n"


echo -e "${RED}This installer currently ONLY works on CentOS 7 and DEBIAN 9${NC}"
echo -e "If your operating system is not on this list then please refer to github for manual install instructions!\n"

echo -e "During this installation, the following dependencies will be installed if they are not already present:"
echo -e "   * Nginx"
echo -e "   * Docker"
echo -e "   * Docker-Compose"
echo -e "   * Certbot\n"

echo -e "During this installation, the following directories will be created if not already present: "
echo -e "   * /opt/ambrest - this is where your blogs will be stored under their domain names."
echo -e "   * /opt/ambrest/logs - this is where the output from the installer will be stored.\n"

echo -e "If you have already used this installer to install a blog, it can still be used to create more instances\n"

echo -e "To confirm that you have read and fully understand and agree to the above statements and the ${PURPLE}vue-blogfront${NC} license found at ${PURPLE}https://git.ambrest.io/Ambrest-Designs-LLC/vue-blogfront${NC}, please type the following numbers: ${NUMBER}\n"

read -p 'Confirmation: ' UserInput

if [[ ! $UserInput = $NUMBER ]]; then
    echo -e "\n${RED}Your input is incorrect. Please fully read the above statements and try again${NC}"
    exit
fi

# Logs
# If ambrest designs folder isn't present, create it
if [[ ! -d /opt/ambrest ]]; then
    mkdir /opt/ambrest >/dev/null
    mkdir /opt/ambrest/logs >/dev/null
fi

echo -e "\n"

read -p 'Name of the new blog instance: ' Name
read -p 'Display name of the new blog instance: ' Displayname
read -p 'Domain of the new blog instance: ' Domain
read -e -p 'Port to expose (default 4000): ' -i '4000' Port
read -e -p 'Port for MongoDB to expose (default 27017): ' -i '27017' Mongo

echo -e "\n"

read -e -p 'Start Docker? (y/n): ' -i 'y' Docker 
read -e -p 'Start Certbot? (y/n): ' -i 'y' Certbot 

# Create Domain folder
mkdir /opt/ambrest/$Domain &>/opt/ambrest/logs/$Domain.log
cd /opt/ambrest/$Domain &>/opt/ambrest/logs/$Domain.log

# Install dependencies
echo -e "\nChecking dependencies...\n"

# Check operating system!

CENTOS="CentOS Linux"
DEBIAN="Debian GNU/Linux"

. /etc/os-release
OS=$NAME
PackageManager=""

# Install on Debian
if [ "$OS" = "$DEBIAN" ]; then

    PackageManager="apt"

# Install on CentOS
elif [ "$OS" = "$CENTOS" ]; then

    PackageManager="yum"

else
    echo -e "\n\n${RED}Your Linux distribution is NOT supported! Do you really think we're dumb enough to let that slide?${NC}"
    echo -e "\nPlease visit https://github.com/ambrest/vue-blogfront for manual installation instructions, and next time read the damn instructions."
    exit
fi

# EPEL-Release is needed for about everything
if [ "$OS" = "$CENTOS" ]; then
    yum install -y epel-release &>/opt/ambrest/logs/$Domain.log
fi

# Nginx
if [[ ! -e /usr/sbin/nginx ]]; then
    echo "Installing NGINX..."

    $PackageManager install -y nginx &>/opt/ambrest/logs/$Domain.log

    systemctl start nginx &>/opt/ambrest/logs/$Domain.log
    systemctl enable nginx &>/opt/ambrest/logs/$Domain.log
fi

# Docker
if [[ ! -e /usr/bin/docker ]]; then
    echo "Installing Docker..."
    
    (curl -fsSL https://get.docker.com/ | sh) &>/opt/ambrest/logs/$Domain.log

    systemctl start docker &>/opt/ambrest/logs/$Domain.log
    systemctl enable docker &>/opt/ambrest/logs/$Domain.log
fi

# Docker-Compose
if [[ ! -e /usr/bin/docker-compose ]]; then
    echo "Installing Docker-Compose..."

    if [[ ! -e /usr/bin/pip ]]; then
        $PackageManager install -y python-pip &>/opt/ambrest/logs/$Domain.log
    fi

    pip install docker-compose &>/opt/ambrest/logs/$Domain.log
fi

# Certbot
if [[ ! -e /usr/bin/certbot ]]; then
    echo "Installing Certbot..."

    if [ "$OS" = "$CENTOS" ]; then 
        yum install -y python2-certbot-nginx &>/opt/ambrest/logs/$Domain.log

        pip install requests urllib3 pyOpenSSL --force --upgrade &>/opt/ambrest/logs/$Domain.log

        pip install requests==2.6.0 &>/opt/ambrest/logs/$Domain.log
        easy_install --upgrade pip &>/opt/ambrest/logs/$Domain.log
    else 
        apt install python-certbot-nginx
    fi
fi

echo -e "\n${GREEN}All dependencies installed!${NC}\n\n"

# Docker-Compose config
echo 'Creating docker-compose.yaml...'
cat >./docker-compose.yaml <<EOL
version: '3'
services:
    blog:
        image: ambrest/vue-blog
        container_name: ${Name}_blog
        command: 
        - "https://${Domain}/api"
        - ${Displayname}
        restart: always
        ports:
        - "${Port}:4000"
        depends_on:
        - mongo
    mongo:
        container_name: ${Name}_mongo
        image: mongo
        volumes:
        - ./data:/data/db
        ports:
        - "${Mongo}:27017"
EOL

# Nginx configuration
echo 'Creating NGINX config...'
cat > /etc/nginx/conf.d/$Domain.conf <<EOL
server {
    listen 80;
    server_name ${Domain};
    location / {
        proxy_pass http://localhost:${Port};
    }
}
EOL

echo -e "\n"

if [ $Docker = 'y' ]; then
    echo 'Starting docker...'

    docker-compose up -d &>/opt/ambrest/logs/$Domain.log

    echo -e "${GREEN}Docker started...${NC}\n"
fi

if [ $Certbot = 'y' ]; then
    echo 'Starting certbot...'

    certbot --nginx 

    echo -e "${GREEN}Certbot done...${NC}"
fi

systemctl restart nginx &>/opt/ambrest/logs/$Domain.log

echo -e "\n\n${PURPLE}vue-blogfront${NC} ${GREEN}installed successfully!${NC}\n"