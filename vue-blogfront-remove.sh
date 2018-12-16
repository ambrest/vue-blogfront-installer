#!/bin/bash

#Colors!
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTBLUE='\033[1;34m'
PURPLE='\033[1;35m'

NC='\033[0m'

NUMBER=$RANDOM

echo -e "By removing $1, all information will be deleted and no longer able to be recovered."
echo -e "This includes all posts, users and other content from the blog."

echo -e "\n${RED}Remove $1 only at YOUR OWN RISK!${NC}\n"

echo -e "To confirm that you have read and fully understand and agree to the above statements, please type the following numbers: ${NUMBER}.\n"

read -p "Confirmation: " UserInput

if [[ ! $UserInput = $NUMBER ]]; then
    echo -e "\n${RED}Your input is incorrect. Please fully read the above statements and try again${NC}"
    exit
fi

if [ -d /opt/ambrest/blogs/$1 ]; then
    cd /opt/ambrest/blogs/$1

    docker-compose down
    cd ..
    rm -rf /opt/ambrest/blogs/$1
    rm -rf /etc/nginx/conf.d/$1.conf

    systemctl restart nginx

    echo -e "\n\n${GREEN}$1 was successfully uninstalled!${NC}"
else
    echo -e "\n${RED}Could not find $1${NC}"
fi