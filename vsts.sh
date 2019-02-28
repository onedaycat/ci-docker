#!/bin/sh

GO_VERSION=1.11
NODE_VERSION=10.6.0
KUBECTL_VERSION=v1.10.3
RANCHER_CLI_VERSION=v2.0.2
HELM_VERSION=v2.9.1

docker build -t onedaycat/ci:vsts \
  --build-arg GO_VERSION=$GO_VERSION \
  --build-arg NODE_VERSION=$NODE_VERSION \
  --build-arg KUBECTL_VERSION=$KUBECTL_VERSION \
  --build-arg RANCHER_CLI_VERSION=$RANCHER_CLI_VERSION \
  --build-arg HELM_VERSION=$HELM_VERSION \
  -f vsts/Dockerfile \
  .

docker push onedaycat/ci:vsts
