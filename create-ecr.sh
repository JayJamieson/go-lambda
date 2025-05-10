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
Usage: $0 --repo-name NAME --region REGION --account-id ID [--auth-only]
  --repo-name    ECR repository name         (required)
  --region       AWS region                  (required)
  --account-id   AWS account ID              (required)
  --auth-only    Only login Docker to ECR and exit
EOF
  exit 1
}

REPO_NAME=""
REGION=""
ACCOUNT_ID=""
AUTH_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-name)  REPO_NAME="$2";   shift 2 ;;
    --region)     REGION="$2";      shift 2 ;;
    --account-id) ACCOUNT_ID="$2";  shift 2 ;;
    --auth-only)  AUTH_ONLY=true;   shift    ;;
    -h|--help)    usage ;;
    *) echo -e "${RED}Unknown option: $1${NC}" >&2; usage ;;
  esac
done

[[ -n "$REPO_NAME" && -n "$REGION" && -n "$ACCOUNT_ID" ]] || usage

ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo -e "${YELLOW}Logging in to ECR registry ${ECR_URI}…${NC}" >&2
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "${ECR_URI}" \
  && echo -e "${GREEN}Docker login succeeded.${NC}" >&2

if $AUTH_ONLY; then
  echo -e "${YELLOW}Auth-only flag set; exiting after login.${NC}" >&2
  exit 0
fi

echo -e "${YELLOW}Creating ECR repository '${REPO_NAME}'…${NC}" >&2
CREATE_OUTPUT=$(aws ecr create-repository \
  --repository-name "$REPO_NAME" \
  --region "$REGION" \
  --image-scanning-configuration scanOnPush=false \
  --image-tag-mutability MUTABLE)
echo -e "${GREEN}Repository creation succeeded.${NC}" >&2

REPO_URI=$(echo "$CREATE_OUTPUT" | jq -r '.repository.repositoryUri')
echo -e "Repository URI: $REPO_URI" >&2

printf '%s\n' "$REPO_URI"
