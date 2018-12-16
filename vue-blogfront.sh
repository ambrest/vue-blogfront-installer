#!/bin/bash

#Colors!
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTBLUE='\033[1;34m'
PURPLE='\033[1;35m'

NC='\033[0m'

CENTOS="CentOS Linux"
DEBIAN="Debian GNU/Linux"

. /etc/os-release
OS=$NAME

if [ "$OS" = "$DEBIAN" ]; then
elif [ "$OS" = "$CENTOS" ]; then
else
    echo -e "\n${RED}Your Linux distribution is NOT supported! Do you really think we're dumb enough to let that slide?${NC}"
    echo -e "\nPlease visit https://github.com/ambrest/vue-blogfront for manual installation instructions, and next time read the damn instructions."
    exit
fi

if [ "$1" = "create" ]; then
    bash /opt/ambrest/scripts/vue-blogfront-create.sh
elif [ "$1" = "remove" ]; then
    bash /opt/ambrest/scripts/vue-blogfront-remove.sh $2
elif [ "$1" = "update" ]; then
    bash /opt/ambrest/scripts/vue-blogfront-update.sh
else 
    echo "Usage: vue-blogfront [create, remove, update]"
fi