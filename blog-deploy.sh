#!/bin/bash
read -p 'Name of the new blog instance: ' Name
read -p 'Domain of the new blog instance: ' Domain
read -e -p 'Port to expose (default 4000): ' -i '4000' Port
read -e -p 'Port for MongoDB to expose (default 27017): ' -i '27017' Mongo
read -e -p 'Start Docker (docker and docker-compose must be installed)? (y/n): ' -i 'y' Docker 
read -e -p 'Start Certbot (certbot must be installed)? (y/n): ' -i 'y' Certbot 

# Create Domain folder
mkdir $Domain
cd $Domain

# Install dependencies

if [! -e /usr/sbin/nginx ]
then
    yum install epel-release -y
    yum install nginx -y

    systemctl start nginx
    systemctl enable nginx
fi

if [! -e /usr/bin/docker ]
then
    yum install curl 
    
    curl -fsSL https://get.docker.com/ | sh

    systemctl start docker
    systemctl enable docker
fi

if [! -e /usr/bin/docker-compose ]
then
    yum install -y python-pip
    pip install docker-compose
fi

if [! -e /usr/bin/certbot ]
then
    yum install python2-certbot-nginx
fi

# Docker-Compose config
echo 'Creating docker-compose.yaml...'
cat >./docker-compose.yaml <<EOL
version: '3'
services:
    blog:
        image: ambrest/vue-blog
        container_name: ${Name}_blog
        command: "https://${Domain}/api"
        restart: always
        ports:
        - "%{Port}:4000"
        depends_on:
        - mongo
    mongo:
        container_name: ${Name}_mongo
        image: mongo
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