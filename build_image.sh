#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

trap 'echo -e "${RED}Error on line ${LINENO}. Aborting.${NC}" >&2; exit 1' ERR

usage() {
  cat <<EOF >&2
Usage: $0 --account-id ID --region REGION --repo-name NAME [--tag TAG]
  --account-id   AWS account ID       (required)
  --region       AWS region           (required)
  --repo-name    ECR repository name  (required)
  --tag          Image tag override; if omitted, use latest Git tag on HEAD
EOF
  exit 1
}

ACCOUNT_ID=""
REGION=""
REPO_NAME=""
TAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --account-id) ACCOUNT_ID="$2"; shift 2 ;;
    --region)      REGION="$2";     shift 2 ;;
    --repo-name)   REPO_NAME="$2";   shift 2 ;;
    --tag)         TAG="$2";        shift 2 ;;
    -h|--help)     usage ;;
    *) echo -e "${RED}Unknown option: $1${NC}" >&2; usage ;;
  esac
done

[[ -n "$ACCOUNT_ID" && -n "$REGION" && -n "$REPO_NAME" ]] || usage

if [[ -n "$TAG" ]]; then
  IMAGE_TAG="$TAG"
  echo -e "${YELLOW}Using override tag: ${IMAGE_TAG}${NC}" >&2
else
  IMAGE_TAG=$(git tag --points-at HEAD --sort=-version:refname | head -n1 || true)
  if [[ -z "$IMAGE_TAG" ]]; then
    echo -e "${YELLOW}No tag found on HEAD; falling back to commit hash${NC}" >&2
    IMAGE_TAG=$(git rev-parse --short HEAD)
  else
    echo -e "${GREEN}Found Git tag on HEAD: ${IMAGE_TAG}${NC}" >&2
  fi
fi

IMAGE_REPO="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}"
IMAGE_URI="${IMAGE_REPO}:${IMAGE_TAG}"

echo -e "${YELLOW}Building Docker image as ${IMAGE_REPO}:${IMAGE_TAG}…${NC}" >&2
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  -t "${IMAGE_REPO}" \
  . >&2
echo -e "${GREEN}Build succeeded.${NC}" >&2

echo -e "${YELLOW}Tagging image…${NC}" >&2
docker tag "${IMAGE_REPO}" "${IMAGE_URI}" >&2
docker tag "${IMAGE_REPO}" "${IMAGE_REPO}:latest" >&2
echo -e "${GREEN}Tagging succeeded.${NC}" >&2

echo -e "${YELLOW}Pushing ${IMAGE_URI}…${NC}" >&2
docker push "${IMAGE_URI}" >&2
echo -e "${GREEN}Pushed ${IMAGE_URI}.${NC}" >&2

echo -e "${YELLOW}Pushing latest tag…${NC}" >&2
docker push "${IMAGE_REPO}:latest" >&2
echo -e "${GREEN}Pushed latest tag.${NC}" >&2

jq -n --arg uri "$IMAGE_URI" '{"image_uri":$uri}'
