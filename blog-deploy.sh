#!/bin/bash

# to run: bash <(curl -s0 https://get-blog.ambrest.io)

read -p 'Name of the new blog instance: ' Name
read -p 'Display name of the new blog instance: ' Displayname
read -p 'Domain of the new blog instance: ' Domain
read -e -p 'Port to expose (default 4000): ' -i '4000' Port
read -e -p 'Port for MongoDB to expose (default 27017): ' -i '27017' Mongo
read -e -p 'Start Docker (docker and docker-compose must be installed)? (y/n): ' -i 'y' Docker 
read -e -p 'Start Certbot (certbot must be installed)? (y/n): ' -i 'y' Certbot 

# If ambrest designs folder isn't present, create it
if [[ ! -d /opt/ambrest ]]; then
    mkdir /opt/ambrest
fi

# Create Domain folder
mkdir /opt/ambrest/$Domain
cd /opt/ambrest/$Domain

# Install dependencies
if [[ ! -e /usr/sbin/nginx ]]; then
    yum install -y epel-release 
    yum install -y nginx 

    systemctl start nginx
    systemctl enable nginx
fi

if [[ ! -e /usr/bin/docker ]]; then
    yum install curl 
    
    curl -fsSL https://get.docker.com/ | sh

    systemctl start docker
    systemctl enable docker
fi

if [[ ! -e /usr/bin/docker-compose ]]; then
    yum install -y python-pip

    pip install --upgrade pip

    pip install docker-compose
fi

if [[ ! -e /usr/bin/certbot ]]; then
    yum install -y python2-certbot-nginx

    pip install requests urllib3 pyOpenSSL --force --upgrade

    pip install requests==2.6.0
    easy_install --upgrade pip
fi

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
echo 'Creating NGINX config'
cat > /etc/nginx/conf.d/$Domain.conf <<EOL
server {
    listen 80;
    server_name ${Domain};
    location / {
        proxy_pass http://localhost:${Port};
    }
}
EOL

if [ $Docker = 'y' ]
then
    echo 'Starting docker...'

    docker-compose up -d

    echo 'Docker started...'
fi

if [ $Certbot = 'y' ]
then
    echo 'Starting certbot...'

    certbot --nginx

    echo 'Certbot done...'
fi

systemctl restart nginx

echo 'Blog successfully installed!'