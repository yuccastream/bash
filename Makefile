.PHONY: build
build: 
	docker build \
		-t yuccastream/ci-tools:latest \
		-f Dockerfile .
