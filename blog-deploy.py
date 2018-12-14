import yaml
import argparse
from subprocess import call

parser = argparse.ArgumentParser(description='Create and deploy a vue-blog instance.')
parser.add_argument('--name', '-n', help='Name of the new blog instance.', type=str)
parser.add_argument('--domain', '-d', help='Domain to deploy the new instance.', type=str)
parser.add_argument('--port', '-p', help='Port for docker to expose.', type=int)
parser.add_argument('--mongo', '-m', help='Port for MongoDB to expose.', type=int)

args = parser.parse_args()

if args.name == None:
    args.name = input('Name of the new blog instance: ')

if args.domain == None:
    args.domain = input('Domain of the new instance: ')

if args.port == None:
    args.port = int(input('Port to expose: '))

if args.mongo == None:
    args.mongo = int(input('Port for MongoDB to expose: '))

args.deploy = (input('Automatically deploy instance with nginx? (y/n): ') == 'y')
args.deploy_docker = (input('Automatically start docker instance? (y/n): ') == 'y')

print('Creating compose file')

docker_compose = """
version: '3'

services:
    blog:
        image: ambrest/vue-blog
        container_name: %s_blog
        command: "https://%s:%i/api"
        restart: always
        ports:
        - "%i:4000"
        depends_on:
        - mongo
    mongo:
        container_name: %s_mongo
        image: mongo
        ports:
        - "%i:27017"
""" % (args.name, args.domain, args.port, args.port, args.name, args.mongo)

nginx_conf = """

server {
    listen 80;
    server_name %s;

    location / {
        proxy_pass http://localhost:%i;
    }
}

""" % (args.domain, args.port)

with open('docker-compose.yaml', 'w') as file:
    file.write(docker_compose)

print('Compose file created...')

if args.deploy == True:
    print('Deploying...')

    with open("/etc/nginx/conf.d/%s.conf", 'w') as file:
        file.write(nginx_conf)

if args.deploy_docker == True:
    print('Starting docker container...')

    call(['docker-compose'], 'up', '-d')
    