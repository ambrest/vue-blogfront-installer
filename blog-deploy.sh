#!/bin/bash
read -p 'Name of the new blog instance: ' Name
read -p 'Domain of the new blog instance: ' Domain
read -p 'Port to expose: ' Port
read -p 'Port for MongoDB to expose: ' Mongo
read -p 'Start Docker (docker and docker-compose must be installed)? (y/n): ' Docker 
read -p 'Start Certbot (certbot must be installed)? (y/n): ' Certbot 

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