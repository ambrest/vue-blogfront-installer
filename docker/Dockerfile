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

WORKDIR /

COPY . .

EXPOSE 4000

RUN chmod +x ./begin.sh
ENTRYPOINT ["bash", "./begin.sh"]
