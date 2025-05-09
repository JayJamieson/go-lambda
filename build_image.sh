#!/bin/bash

# Prepare image tags
ORG_NAME="jayjamieson"
IMAGE_REPO_NAME="go-lambda"
IMAGE_REPO="docker.io/${ORG_NAME}/${IMAGE_REPO_NAME}"

IMAGE_TAG="$(git rev-parse --short HEAD).$(date '+%s')"
IMAGE_URI="${IMAGE_REPO}:${IMAGE_TAG}"

echo "docker_image: $IMAGE_URI"
echo "image tag: ${IMAGE_TAG}"



# Build image
docker build --build-arg VERSION="${IMAGE_TAG}" -t $IMAGE_REPO . --no-cache --rm

# Tag image

docker tag $IMAGE_REPO $IMAGE_URI

# Deploy image

docker push $IMAGE_URI
