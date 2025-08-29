#!/usr/bin/env bash
set -euo pipefail

DOCKERHUB_USER="${DOCKERHUB_USER:-yourdockerhubusername}"
REPO="${REPO:-dev}"
TAG="${TAG:-latest}"

IMAGE="${IMAGE:-${DOCKERHUB_USER}/${REPO}:${TAG}}"
export IMAGE

echo ">> Pulling $IMAGE"
docker pull "$IMAGE" || true

echo ">> (Re)starting container"
docker compose -f docker-compose.yml down || true
docker compose -f docker-compose.yml up -d

echo ">> Current status:"
docker compose -f docker-compose.yml ps
