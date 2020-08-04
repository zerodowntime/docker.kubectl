##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

KUBECTL_VERSION ?= latest

DOCKER_REPO ?= $(subst .,/,$(notdir $(PWD)))
DOCKER_TAG  ?= ${KUBECTL_VERSION}

, = ,
ALL_TAGS = $(subst $(,), ,$(DOCKER_TAG))
TAG_LIST = $(foreach tag,$(ALL_TAGS),-t "$(DOCKER_REPO):$(tag)")
ARG_LIST = $(foreach arg,$(BUILD_ARGS),--build-arg "$(arg)")

BUILD_ARGS += KUBECTL_VERSION=${KUBECTL_VERSION}

image: build push

build:
	docker image build $(TAG_LIST) $(ARG_LIST) .

push:
	$(foreach tag,$(ALL_TAGS),docker image push "$(DOCKER_REPO):$(tag)" &&) true

clean:
	docker image rm "${IMAGE_NAME}:${IMAGE_TAG}"

stable-%: KUBECTL_VERSION = $(shell curl -s -L https://dl.k8s.io/release/stable-$*.txt)
stable-%: DOCKER_TAG = $@,$(KUBECTL_VERSION)
stable-%:
	$(MAKE) image KUBECTL_VERSION=$(KUBECTL_VERSION) DOCKER_TAG=$(DOCKER_TAG)

stable: stable-1.14
stable: stable-1.15
stable: stable-1.16
stable: stable-1.17
stable: stable-1.18
