# TODO: Remove compose
# TODO: Move container build commands into ci/scripts
# TODO: Add container labels

UBUNTU_VERSION = focal-20220404

VERSION = $(shell cat VERSION)

IMAGE_NAME = docker.io/alikov/unifi-network-application
IMAGE_TAG = $(VERSION)

ifneq ($(CONTAINER_HOST),)
PODMAN_REMOTE_FLAG := --remote
endif

TARGETARCH = $(shell podman $(PODMAN_REMOTE_FLAG) run --rm ubuntu:$(UBUNTU_VERSION) arch | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')

ifeq ($(TARGETARCH),)
$(error TARGETARCH is not set!)
endif

.PHONY: build update-versionlock compose compose-down compose-down-mrproper trivy-scan

build:
	podman $(PODMAN_REMOTE_FLAG) build \
	  -t $(IMAGE_NAME):$(IMAGE_TAG)-$(TARGETARCH) \
	  --build-arg TARGETARCH=$(TARGETARCH) \
	  --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
	  .

update-versionlock:
	podman $(PODMAN_REMOTE_FLAG) run -i --rm ubuntu:$(UBUNTU_VERSION) bash <generate-versionlock.sh >"versionlock-1001-$(TARGETARCH)"

compose:
	-podman secret rm unifi-mongo-username
	-podman secret rm unifi-mongo-password
	echo 'unifiuser' | podman secret create unifi-mongo-username -
	echo 'hunter2' | podman secret create unifi-mongo-password -
	podman-compose up -d

compose-down:
	podman-compose down

compose-down-mrproper:
	podman-compose down -v

# Might need to do systemctl --user enable --now podman.socket
# See https://aquasecurity.github.io/trivy/v0.26.0/docs/advanced/container/podman/
trivy-scan:
	trivy image --ignore-unfixed $(IMAGE_NAME):$(IMAGE_TAG)-$(TARGETARCH)
