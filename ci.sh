#!/bin/sh

KUBECTL_VERSION=v1.10.3
HELM_VERSION=v2.9.1
GOLANG_VERSION=1.12

docker build -t onedaycat/ci \
  --build-arg KUBECTL_VERSION=$KUBECTL_VERSION \
  --build-arg HELM_VERSION=$HELM_VERSION \
  --build-arg GOLANG_VERSION=$GOLANG_VERSION \
  -f ci/Dockerfile \
  .


