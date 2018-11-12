#!/bin/sh

DOCKER_VERSION=17.04.0-ce
KUBECTL_VERSION=v1.10.3
RANCHER_CLI_VERSION=v2.0.4
HELM_VERSION=v2.9.1
GOLANG_VERSION=1.11.2

docker build -t onedaycat/ci:go \
  --build-arg DOCKER_VERSION=$DOCKER_VERSION \
  --build-arg KUBECTL_VERSION=$KUBECTL_VERSION \
  --build-arg RANCHER_CLI_VERSION=$RANCHER_CLI_VERSION \
  --build-arg HELM_VERSION=$HELM_VERSION \
  -f ci/go/Dockerfile \
  .

docker build -t onedaycat/ci:node \
  --build-arg DOCKER_VERSION=$DOCKER_VERSION \
  --build-arg KUBECTL_VERSION=$KUBECTL_VERSION \
  --build-arg RANCHER_CLI_VERSION=$RANCHER_CLI_VERSION \
  --build-arg HELM_VERSION=$HELM_VERSION \
  -f ci/node/Dockerfile \
  .

docker build -t onedaycat/ci \
  --build-arg GOLANG_VERSION=$GOLANG_VERSION \
  -f ci/Dockerfile \
  .


