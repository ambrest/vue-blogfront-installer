#!/bin/bash

if [ -d "/tmp/vue-blogfront" ]; then
  # Unpack & build frontend
    cd /tmp/vue-blogfront

    echo "Configuring blogfront..."
    json -I -f ./config/config.json -e "this.apiEndPoint='$1'"

    echo "Installing NPM modules..."
    npm install

    echo "Building blogfront..."
    npm run build

    cp -r ./dist /opt/ambrest/vue-blog/dist

    cd /opt/ambrest/vue-blog

    echo "Removing source..."
    rm -rf /tmp/vue-blogfront

    # Unpack server

    cd /opt/ambrest/vue-blog/backend

    echo "Installing backend..."
    npm install
fi

cd /opt/ambrest/vue-blog/backend

echo "Launching application..."
npm run launch-docker
