FROM node:lts-stretch-slim
MAINTAINER Ambrest Designs LLC <contact@ambrest.io>

# Update & install dependencies
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install git -y

RUN npm install -g json

# Setup directories
RUN mkdir /opt/ambrest
RUN mkdir /opt/ambrest/vue-blog

# Grab the repositories

WORKDIR /tmp

RUN git clone https://git.ambrest.io/Ambrest-Designs-LLC/vue-blogfront.git

WORKDIR vue-blogfront
RUN npm install

RUN git clone https://git.ambrest.io/Ambrest-Designs-LLC/vue-blog-backend.git /opt/ambrest/vue-blog/backend

WORKDIR /opt/ambrest/vue-blog/backend
RUN npm install

WORKDIR /

COPY . .

EXPOSE 4000

RUN chmod +x ./begin.sh
ENTRYPOINT ["bash", "./begin.sh"]
