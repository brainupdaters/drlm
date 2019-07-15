#!/bin/bash

DOCKER_DIR=${PWD}/packaging/docker

source ${DOCKER_DIR}/env.conf

echo "${0}: Build the docker images: ${DOCKER_IMAGE}:${DOCKER_TAG}"
docker build --rm --compress -t ${DOCKER_IMAGE}:${DOCKER_TAG} ./src
