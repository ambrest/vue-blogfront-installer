#!/bin/bash
read -p 'Name of the new blog instance: ' Name
read -p 'Domain of the new blog instance: ' Domain
read -p 'Port to expose: ' Port
read -p 'Port for MongoDB to expose: ' Mongo
read -p 'Deploy with NGINX (nginx must be installed)? (y/n): ' Nginx 
read -p 'Start Docker (docker and docker-compose must be installed)? (y/n): ' Docker 
read -p 'Start Certbot (certbot must be installed)? (y/n): ' Certbot 

# Docker-Compose config
IFS='' read -r -d '' DockerCompose <<"EOF"
version: '3'
services:
    blog:
        image: ambrest/vue-blog
        container_name: %s_blog
        command: "https://%s/api"
        restart: always
        ports:
        - "%s:4000"
        depends_on:
        - mongo
    mongo:
        container_name: %s_mongo
        image: mongo
        ports:
        - "%s:27017"
EOF

# Nginx configuration
IFS='' read -r -d '' NginxConf <<"EOF"
server {
    listen 80;
    server_name %s;
    location / {
        proxy_pass http://localhost:%s;
    }
}
EOF

echo 'Creating docker-compose.yaml...'
printf $DockerCompose $Name $Domain $Port $Name $Mongo > './docker-compose.yaml'

echo 'Created docker-compose.yaml...\n'

if [ $Nginx = 'y' ]
then
    echo 'Generating NGINX config...'

    printf $NginxConf $Domain $Port > printf '/etc/nginx/conf.d/%s.conf' $Domain

    echo 'NGINX config generated...\n'
fi

if [ $Docker = 'y' ]
then
    echo 'Starting docker...'

    docker-compse up -d

    echo 'Docker started...\n'
fi

if [ $Certbot = 'y' ]
then
    echo 'Starting certbot...'

    certbot --nginx

    echo 'Certbot done...\n'
fi

systemctl restart nginx

echo 'Blog successfully installed!'