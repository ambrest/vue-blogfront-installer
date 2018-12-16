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

echo -e "The ${PURPLE}vue-blogfront${NC} cli tool will be created for you during this installation. \n"

echo -e "During this installation, the following directories will be created if not already present: "
echo -e "   * /opt/ambrest - this is where your blogs will be stored under their domain names."
echo -e "   * /opt/ambrest/scripts - this is where the vue-blogfront cli tool will be installed."
echo -e "   * /opt/ambrest/logs - this is where the output from the installer will be stored.\n"

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
    mkdir /opt/ambrest/scripts >/dev/null
    mkdir /opt/ambrest/blogs >/dev/null
    mkdir /opt/ambrest/logs >/dev/null
fi

echo -e "\nInstalling ${PURPLE}vue-blogfront${NC} ..."

# Get scripts
curl -s0 https://get-blog.ambrest.io/vue-blogfront.sh > /opt/ambrest/scripts/vue-blogfront.sh
curl -s0 https://get-blog.ambrest.io/vue-blogfront-create.sh > /opt/ambrest/scripts/vue-blogfront-create.sh
curl -s0 https://get-blog.ambrest.io/vue-blogfront-remove.sh > /opt/ambrest/scripts/vue-blogfront-remove.sh
curl -s0 https://get-blog.ambrest.io/vue-blogfront-update.sh > /opt/ambrest/scripts/vue-blogfront-update.sh

chmod +x /opt/ambrest/scripts/vue-blogfront.sh
chmod +x /opt/ambrest/scripts/vue-blogfront-create.sh
chmod +x /opt/ambrest/scripts/vue-blogfront-remove.sh
chmod +x /opt/ambrest/scripts/vue-blogfront-update.sh

ln -sf /opt/ambrest/scripts/vue-blogfront.sh /usr/sbin/vue-blogfront

echo -e "${PURPLE}vue-blogfront${NC} was ${GREEN}successfully installed!${NC}"