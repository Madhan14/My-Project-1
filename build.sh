#!/usr/bin/env bash
set -euo pipefail

APP_NAME="devops-build"
DOCKERHUB_USER="${DOCKERHUB_USER:-yourdockerhubusername}"
DEV_REPO="${DEV_REPO:-dev}"
PROD_REPO="${PROD_REPO:-prod}"

BRANCH="${1:-local}"
COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo local)"
TAG="v$(date +%Y%m%d%H%M%S)-${COMMIT}"

if [[ "$BRANCH" == "dev" ]]; then
  TARGET_REPO="$PROD_REPO"
else
  TARGET_REPO="$DEV_REPO"
fi

IMAGE="${DOCKERHUB_USER}/${TARGET_REPO}:${TAG}"
LATEST="${DOCKERHUB_USER}/${TARGET_REPO}:latest"

echo ">> Building image: $IMAGE"
docker build -t "$IMAGE" -t "$LATEST" -f Dockerfile .

echo ">> Built images:"
docker images | grep "$DOCKERHUB_USER" | grep "$TARGET_REPO" | head -n 5

echo "Done. To push: docker push $IMAGE && docker push $LATEST"
