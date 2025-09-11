#!/bin/bash

# Define variables
PROD_SERVER="rverrill@rwvaquinas.duckdns.org"  # Replace with your server's IP or hostname
PROD_DIR="/home/rverrill/thomas"  # Directory on production server
LOCAL_DIR="/home/robert/Aquinas-search-engine"  # Local directory with your app files
IMAGE_NAME="rwv1001/aquinas-search-engine"  # Replace with your Docker Hub username and app name
IMAGE_NAME_ESC="rwv1001\/aquinas-search-engine"
IMAGE_TAG=$(git rev-parse --short HEAD) # Or use a specific version tag, e.g., "v1.0"
echo "Build the Docker image locally"
# Build the Docker image locally
docker build -t $IMAGE_NAME:$IMAGE_TAG -f production.Dockerfile .
#echo "logging in to Docker Hub"
#docker login
echo "Pushing the image to Docker Hub"
# Push the image to Docker Hub
docker push $IMAGE_NAME:$IMAGE_TAG
echo "Copying files to production server"
scp -P 22222 docker-compose-pull.yml "$PROD_SERVER:$PROD_DIR"
echo "updating image tag in .env file"
sed -i "s/^ENV_IMAGE_TAG=.*/ENV_IMAGE_TAG=${IMAGE_TAG}/" .env
sed -i "s/^ENV_IMAGE_NAME=.*/ENV_IMAGE_NAME=${IMAGE_NAME_ESC}/" .env
echo "Copying .env file to production server"
scp -P 22222 .env "$PROD_SERVER:$PROD_DIR"
scp -P 22222 restoredb-remote.sh "$PROD_SERVER:$PROD_DIR"
echo "Pulling the latest image on the production server"
ssh -p 22222 "$PROD_SERVER" "docker pull $IMAGE_NAME:$IMAGE_TAG && cd $PROD_DIR && docker compose -f docker-compose-pull.yml down -v && docker compose -f docker-compose-pull.yml up -d --build && sleep 20 && ./restoredb-remote.sh && echo 'Exit code: $?'"

