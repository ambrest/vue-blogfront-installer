FROM node:lts-stretch-slim
MAINTAINER Ambrest Designs LLC <contact@ambrest.io>

# Update & install dependencies
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install git -y

# Setup directories
RUN mkdir /opt/ambrest
RUN mkdir /opt/ambrest/vue-blog

# Grab the repositories
WORKDIR /tmp

RUN git clone https://git.ambrest.io/Ambrest-Designs-LLC/vue-blogfront.git

# Unpack & build frontend
WORKDIR /tmp/vue-blogfront

RUN npm install
RUN npm run build

RUN cp -r ./dist /opt/ambrest/vue-blog/dist

WORKDIR /opt/ambrest/vue-blog

RUN rm -rf /tmp/vue-blogfront

# Unpack server
RUN git clone https://git.ambrest.io/Ambrest-Designs-LLC/vue-blog-backend.git backend

WORKDIR /opt/ambrest/vue-blog/backend

RUN npm install

EXPOSE 4000

CMD npm run launch-docker
