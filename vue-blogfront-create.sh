#!/usr/bin/env bash
echo -e "\n\nDuring this installation, the following dependencies will be installed if they are not already present:"
echo -e "   * Nginx"
echo -e "   * Docker"
echo -e "   * Docker-Compose"
echo -e "   * Certbot\n"

echo -e "\n"

read -p 'Name of the new blog instance: ' Name
read -p 'Display name of the new blog instance: ' Displayname
read -p 'Domain of the new blog instance: ' Domain
read -e -p 'Port to expose (default 4000): ' -i '4000' Port
read -e -p 'Port for MongoDB to expose (default 27017): ' -i '27017' Mongo

echo -e "\n"

read -e -p 'Start Docker? (y/n): ' -i 'y' Docker
read -e -p 'Start Certbot? (y/n): ' -i 'y' Certbot

# Create Domain folder
mkdir /opt/ambrest/blogs/$Domain &>/opt/ambrest/logs/$Domain.log
mkdir /opt/ambrest/blogs/$Domain/config &>/opt/ambrest/logs/$Domain.log
cd /opt/ambrest/blogs/$Domain &>/opt/ambrest/logs/$Domain.log

# Install dependencies
echo -e "\nChecking dependencies...\n"

# Check operating system!

CENTOS="CentOS Linux"
DEBIAN="Debian GNU/Linux"

. /etc/os-release
OS=$NAME
PackageManager=""

# Install on Debian
if [ "$OS" = "$DEBIAN" ]; then

    PackageManager="apt"

# Install on CentOS
elif [ "$OS" = "$CENTOS" ]; then

    PackageManager="yum"

else
    echo -e "\n\n${RED}Your Linux distribution is NOT supported! Do you really think we're dumb enough to let that slide?${NC}"
    echo -e "\nPlease visit https://github.com/ambrest/vue-blogfront for manual installation instructions, and next time read the damn instructions."
    exit
fi

# EPEL-Release is needed for about everything
if [ "$OS" = "$CENTOS" ]; then
    yum install -y epel-release &>/opt/ambrest/logs/$Domain.log
fi

# Nginx
if [[ ! -e /usr/sbin/nginx ]]; then
    echo "Installing NGINX..."

    $PackageManager install -y nginx &>/opt/ambrest/logs/$Domain.log

    systemctl start nginx &>/opt/ambrest/logs/$Domain.log
    systemctl enable nginx &>/opt/ambrest/logs/$Domain.log
fi

# Docker
if [[ ! -e /usr/bin/docker ]]; then
    echo "Installing Docker..."

    (curl -fsSL https://get.docker.com/ | sh) &>/opt/ambrest/logs/$Domain.log

    systemctl start docker &>/opt/ambrest/logs/$Domain.log
    systemctl enable docker &>/opt/ambrest/logs/$Domain.log
fi

# Docker-Compose
if [[ ! -e /usr/bin/docker-compose ]]; then
    echo "Installing Docker-Compose..."

    if [[ ! -e /usr/bin/pip ]]; then
        $PackageManager install -y python-pip &>/opt/ambrest/logs/$Domain.log
    fi

    pip install docker-compose &>/opt/ambrest/logs/$Domain.log
fi

# Certbot
if [[ ! -e /usr/bin/certbot ]]; then
    echo "Installing Certbot..."

    if [ "$OS" = "$CENTOS" ]; then
        yum install -y python2-certbot-nginx &>/opt/ambrest/logs/$Domain.log

        pip install requests urllib3 pyOpenSSL --force --upgrade &>/opt/ambrest/logs/$Domain.log

        pip install requests==2.6.0 &>/opt/ambrest/logs/$Domain.log
        easy_install --upgrade pip &>/opt/ambrest/logs/$Domain.log
    else
        apt install -y python-certbot-nginx
    fi
fi

echo -e "\n${GREEN}All dependencies installed!${NC}\n\n"

# Docker-Compose config
echo 'Creating docker configuration...'
cat >./docker-compose.yaml <<EOL
version: '3'
services:
    blog:
        image: ambrest/vue-blog
        container_name: ${Name}_blog
        restart: always
        volumes:
        - ./config:/config
        ports:
        - "${Port}:4000"
        depends_on:
        - mongo
    mongo:
        container_name: ${Name}_mongo
        image: mongo
        restart: always
        volumes:
        - ./data:/data/db
        ports:
        - "${Mongo}:27017"
EOL

# Nginx configuration
echo 'Creating NGINX configuration...'
cat > /etc/nginx/conf.d/$Domain.conf <<EOL
server {
    listen 80;
    server_name ${Domain};

    location / {
        proxy_pass http://localhost:${Port};
    }

    # Restrict TLS protocols and some ssl improvements
    ssl_protocols TLSv1.2;
    ssl_ecdh_curve secp521r1:secp384r1;

    # Hide upstream proxy headers
    proxy_hide_header X-Powered-By;
    proxy_hide_header X-AspNetMvc-Version;
    proxy_hide_header X-AspNet-Version;
    proxy_hide_header X-Drupal-Cache;
    # Custom headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains" always;
    add_header Referrer-Policy "no-referrer";
    add_header Feature-Policy "geolocation none; midi none; notifications none; push none; sync-xhr none; microphone none; camera none; magnetometer none; gyroscope none; speaker none; vibrate none; fullscreen self; payment none; usb none;";
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;

    # Close slow connections (in case of slow loris attack)
    client_body_timeout 10s;
    client_header_timeout 10s;
    keepalive_timeout 5s 5s;
    send_timeout 10s;
}
EOL

# vue-blogfront configuration
echo 'Creating vue-blogfront configuration...'
cat > ./config/blogfront.config.json <<EOL
{
    "pageTitle": "${Displayname}",
    "themeColor": "#C62642",
    "apiEndPoint": "https://${Domain}/api",
    "wordsPerMinute": 250,
    "postsPreloadAmount": 3,

    "meta": {
        "description": "Vue blogfront - PWA for blogs. 100% Offline.",
        "keywords": "Blog,Blog-engine,Vue-app,Vue,Vue2,PWA,SPA,WebApp",
        "author": "Ambrest Designs"
    }
}
EOL

# vue-blogfront-api configuration
echo 'Creating vue-blogfront-api configuration...'
cat > ./config/api.config.json <<EOL
{
    "info": {
        "author": "Ambrest Designs LLC",
        "title": "${Displayname}",
        "version": 1.0
    },
    "server": {
        "port": 4000,
        "startingMessage": "Server started on port 4000...",
        "domain": "https://${Domain}",
        "api": "https://${Domain}",
        "emailVerification": false
    },
    "mail": {
        "service": "",
        "secure": "",
        "port": 0,
        "auth": {
            "user": "",
            "pass": ""
        }
    },
    "auth": {
        "apikeyExpiry": 12960000000,
        "saltRounds": 10
    }
}
EOL

echo -e "\n"

if [ $Docker = 'y' ]; then
    echo 'Starting docker...'

    docker-compose pull && docker-compose up -d &>/opt/ambrest/logs/$Domain.log

    echo -e "${GREEN}Docker started...${NC}\n"
fi

if [ $Certbot = 'y' ]; then
    echo 'Starting certbot...'

    certbot --nginx

    echo -e "${GREEN}Certbot done...${NC}"
fi

systemctl restart nginx &>/opt/ambrest/logs/$Domain.log

echo -e "\n\n${PURPLE}vue-blogfront${NC} ${GREEN}installed successfully!${NC}\n"

echo -e "You can furthur configure your ${PURPLE}vue-blogfront${NC} instance in /opt/ambrest/${Domain}/config, then run ${PURPLE}vue-blogfront update${NC}.\n"
