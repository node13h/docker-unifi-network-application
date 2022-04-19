UBUNTU_VERSION = focal-20220404

VERSION = $(shell cat VERSION)

IMAGE_NAME = docker.io/alikov/unifi-network-application
IMAGE_TAG = $(VERSION)

.PHONY: build update-versionlock compose compose-down compose-down-mrproper

build:
	podman build \
	  -t $(IMAGE_NAME):$(IMAGE_TAG) \
	  --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
	  .
	podman tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):latest

update-versionlock:
	podman run -i ubuntu:$(UBUNTU_VERSION) bash <generate-versionlock.sh >versionlock-1001

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
	trivy image --ignore-unfixed $(IMAGE_NAME):$(IMAGE_TAG)
