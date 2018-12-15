#!/bin/bash

# Grab the repositories

cd /tmp

# Install production version of vue-blogfront
echo "Updating vue-blogfront..."
git clone https://git.ambrest.io/Ambrest-Designs-LLC/vue-blogfront.git
cd /tmp/vue-blogfront
git checkout production

echo "Configuring vue-blogfront..."
json -I -f ./config/config.json -e "this.apiEndPoint='$1'"
json -I -f ./config/config.json -e "this.pageTitle='$2'"

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
git clone https://git.ambrest.io/Ambrest-Designs-LLC/vue-blogfront-api.git /opt/ambrest/vue-blog/backend
cd /opt/ambrest/vue-blog/backend
git checkout production

echo "Installing vue-blogfront-api dependencies..."
npm install

echo "Configuring vue-blogfront-api..."
npm run configure

echo "Launching application..."
npm run launch-docker
