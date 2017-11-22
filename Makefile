BUILD_DIR := $(PWD)
DOCKER_BUILD := tmp/docker-build
DOCKER_IMAGE := pmp-build
DOCKER_CONTAINER := pmp-builder

$(DOCKER_BUILD):
	docker build --file ./docker/dockerfiles/build-environment --tag $(DOCKER_IMAGE) ./docker
	mkdir -p $(@D)
	touch $@

.PHONY: build
build: $(DOCKER_BUILD)
	# docker stop $(DOCKER_CONTAINER)
	# docker rm $(DOCKER_CONTAINER)

	docker ps -a | grep $(DOCKER_CONTAINER) || docker run -t -d \
		--volume $(BUILD_DIR):/plex \
		--workdir /plex \
		--env PLEX_TAG=master \
		--name $(DOCKER_CONTAINER) \
		--device /dev/fuse \
		--privileged \
		$(DOCKER_IMAGE)

	docker exec -t $(DOCKER_CONTAINER) ./scripts/build.sh

	docker stop $(DOCKER_CONTAINER)

.PHONY: clean
clean:
	rm -rf $(DOCKER_BUILD)
