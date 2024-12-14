PHONY: build-local-amd64 build-local-arm64 build-multiarch push-multiarch release

VERSION=0.10.0
INTERMEDIATE_REPOSITORY=localhost:5050
END_REPOSITORY=ghcr.io

IMAGE_NAME=akrizs/rmqtt-devc

# Build linux/amd64 locally!
build-local-amd64:
	@docker buildx build \
  		--platform linux/amd64 \
  		--build-arg TARGET_ARCH=x86_64-unknown-linux-musl \
  		-t rmqtt-devc:latest \
		--load \
		.

# Build linux/arm64 locally!
build-local-arm64:
	@docker buildx build \
		--platform linux/arm64 \
		--build-arg TARGET_ARCH=aarch64-unknown-linux-musl \
		-t rmqtt-devc:latest \
		--load \
		.

# Run image locally!
run-local:
	@docker run -it \
		--rm \
		--name rmqtt-devc \
		rmqtt-devc:latest \
		/bin/bash

# Build MultiArch for release!
build-multiarch:
	@./build-multiarch.sh $(INTERMEDIATE_REPOSITORY) $(IMAGE_NAME) $(VERSION)

# Push MultiArch for release!
push-multiarch:
	regctl image copy $(INTERMEDIATE_REPOSITORY)/$(IMAGE_NAME):$(VERSION) $(END_REPOSITORY)/$(IMAGE_NAME):$(VERSION)
	regctl image copy $(INTERMEDIATE_REPOSITORY)/$(IMAGE_NAME):latest $(END_REPOSITORY)/$(IMAGE_NAME):latest

# MultiArch Release!
release:
	@make build-multiarch
	@make push-multiarch
