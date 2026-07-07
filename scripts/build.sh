#!/usr/bin/env bash
set -euo pipefail

IMAGE_BASE="dotlupa/playground"
TAG="latest"
TARGET_PLATFORM="${1:-}"

if [[ "$TARGET_PLATFORM" == "--help" || "$TARGET_PLATFORM" == "-h" ]]; then
  cat <<EOF >&2
Usage: $0 [platform]

Options:
  -h, --help    Show this help message and exit

Platforms (Optional):
  linux/amd64   Build for Intel/AMD architecture
  linux/arm64   Build for Apple Silicon/ARM architecture

Note: If no platform is specified, a native build is performed.
      Repeatedly building different platforms will create <none> images.
      Run 'docker image prune -f' to clean up disk space.
EOF
  exit 0
fi

if [[ -n "$TARGET_PLATFORM" ]]; then
  echo "[INFO] Starting target platform build"
  echo "  platform: ${TARGET_PLATFORM}"
  echo "  image:    ${IMAGE_BASE}"

  if ! docker buildx ls | grep -q "mybuilder"; then
    echo "[INFO] Creating new buildx builder 'mybuilder'..."
    docker buildx create --name mybuilder --use
  else
    echo "[INFO] Using existing builder 'mybuilder'..."
    docker buildx use mybuilder
  fi

  docker buildx build \
    --platform "$TARGET_PLATFORM" \
    -t "${IMAGE_BASE}:${TAG}" \
    --load .
else
  echo "[INFO] Starting native build for current architecture..."
  docker build -t "${IMAGE_BASE}:${TAG}" .
fi

echo "[SUCCESS] Image build completed: ${IMAGE_BASE}:${TAG}"
