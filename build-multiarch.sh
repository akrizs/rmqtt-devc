#!/usr/bin/env bash
set -e

REGISTRY_URI="$1"
IMAGE_NAME="$2"
VERSION="$3"

if [ -z "$REGISTRY_URI" ] || [ -z "$IMAGE_NAME" ] || [ -z "$VERSION" ]; then
    echo "Usage: $0 <registry_uri> <image_name> <version>"
    exit 1
fi

FULL_IMAGE="${REGISTRY_URI}/${IMAGE_NAME}"

ARCHS=("linux/amd64" "linux/arm64")
SHA256_DIGESTS=()

for ARCH in "${ARCHS[@]}"; do
    PLATFORM_TAG=$(echo "$ARCH" | tr '/' '-')
    if [ "$ARCH" = "linux/amd64" ]; then
        TARGET_ARCH="x86_64-unknown-linux-musl"
    else
        TARGET_ARCH="aarch64-unknown-linux-musl"
    fi

    docker buildx build \
        --platform "$ARCH" \
        --build-arg TARGET_ARCH="$TARGET_ARCH" \
        -t "${FULL_IMAGE}:${PLATFORM_TAG}-${VERSION}" \
        --push \
        .
    # --output push-by-digest=true,type=image,push=true \

    DIGEST=$(docker buildx imagetools inspect "${FULL_IMAGE}:${PLATFORM_TAG}-${VERSION}" | grep "Digest:" | head -n1 | awk '{print $2}')
    if [ -z "$DIGEST" ]; then
        echo "Error extracting digest for $ARCH"
        exit 1
    fi
    SHA256_DIGESTS+=("${FULL_IMAGE}@${DIGEST}")
done

docker buildx imagetools create -t "${FULL_IMAGE}:${VERSION}" -t "${FULL_IMAGE}:latest" "${SHA256_DIGESTS[@]}"

echo "Multi-arch manifest created and pushed:"
echo "${FULL_IMAGE}:${VERSION}"
echo "${FULL_IMAGE}:latest"
