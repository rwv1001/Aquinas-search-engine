#!/bin/bash

# Define variables
PROD_SERVER="rwvagatha.duckdns.org"  # Replace with your server's IP or hostname
PROD_DIR="/home/robert/agatha"  # Directory on production server
LOCAL_DIR="/home/robert/agathaDev/PhilosophyFinder"  # Local directory with your app files
IMAGE_NAME="rwv1001/agatha"  # Replace with your Docker Hub username and app name
IMAGE_TAG=$(git rev-parse --short HEAD) # Or use a specific version tag, e.g., "v1.0"

# Build the Docker image locally
docker build -t $IMAGE_NAME:$IMAGE_TAG -f production.Dockerfile .

# Push the image to Docker Hub
docker push $IMAGE_NAME:$IMAGE_TAG

scp docker-compose-pull.yml "$PROD_SERVER:$PROD_DIR"

sed -i "s/^ENV_IMAGE_TAG=.*/ENV_IMAGE_TAG=${IMAGE_TAG}/" .env

scp .env "$PROD_SERVER:$PROD_DIR"

ssh "$PROD_SERVER" "docker pull $IMAGE_NAME:$IMAGE_TAG && cd $PROD_DIR && docker compose -f docker-compose-pull.yml down -v && docker compose -f docker-compose-pull.yml up -d --build"