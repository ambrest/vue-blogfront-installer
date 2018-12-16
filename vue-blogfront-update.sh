#!/bin/bash

#Colors!
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTBLUE='\033[1;34m'
PURPLE='\033[1;35m'

NC='\033[0m'

cd /opt/ambrest/blogs
for d in */; do
    echo -e "${GREEN}Updating $d...${NC}"

    cd "$d"

    docker-compose down &> "/opt/ambrest/logs/${d}update.log"
    docker-compose up &> "/opt/ambrest/logs/${d}update.log"

    cd ..
done