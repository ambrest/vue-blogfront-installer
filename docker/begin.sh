#!/bin/bash

# Grab the repositories

cd /tmp

# Install production version of vue-blogfront
echo "Updating vue-blogfront..."
git clone https://github.com/ambrest/vue-blogfront.git
cd /tmp/vue-blogfront

echo "Configuring vue-blogfront..."
rm -rf ./config/config.json
cp -r /config/blogfront.config.json ./config/config.json

echo "Installing vue-blogfront dependencies..."
npm install

echo "Building vue-blogfront..."
npm run build

echo "Copying files..."
cp -r ./dist /opt/ambrest/vue-blog/dist

cd /opt/ambrest/vue-blog

echo "Removing source..."
rm -rf /tmp/vue-blogfront

# Install production version of vue-blogfront-api
echo "Updating vue-blogfront-api..."
git clone https://github.com/ambrest/vue-blogfront-api.git /opt/ambrest/vue-blog/backend
cd /opt/ambrest/vue-blog/backend

echo "Installing vue-blogfront-api dependencies..."
npm install

echo "Configuring vue-blogfront-api..."
rm -rf ./config/config.json
cp -r /config/api.config.json ./config/config.json

echo "Launching application..."
npm run launch-docker
