FROM golang:1.12-alpine

RUN apk add --no-cache tar gzip curl git openssh-client bash g++ ca-certificates

ARG DOCKER_CHANNEL=edge
ARG DOCKER_VERSION=17.04.0-ce
ARG KUBECTL_VERSION=v1.10.3
ARG RANCHER_CLI_VERSION=v2.0.4
ARG HELM_VERSION=v2.9.1

ENV GO111MODULE=auto

RUN set -x && \
  curl -fSL "https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz" -o helm.tar.gz && \
  tar -xzvf helm.tar.gz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  rm -rf linux-amd64 helm.tar.gz && \
  helm version -c && \
  curl -fSL "https://releases.rancher.com/cli/${RANCHER_CLI_VERSION}/rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz" -o rancher.tar.gz && \
  tar -xzvf rancher.tar.gz && \
  mv rancher-${RANCHER_CLI_VERSION}/rancher /usr/local/bin/rancher && \
  rm -rf rancher-${RANCHER_CLI_VERSION} rancher.tar.gz && \
  rancher -v && \
  curl -fL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz && \
  tar -xzvf docker.tgz && \
  mv docker/* /usr/local/bin/ && \
  rmdir docker && \
  rm docker.tgz && \
  docker -v && \
  curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
  mv kubectl /usr/local/bin/ && \
  chmod +x /usr/local/bin/kubectl && \
  go get -u github.com/jteeuwen/go-bindata/... && \
  go get -u github.com/onedaycat/zamus/zamus && \
  go get -u github.com/onedaycat/vtlgen/vtlgen && \
  go get -u github.com/onedaycat/gqlscalars/gqlscalars && \
  go get -u github.com/plimble/mage/... && \
  $GOPATH/src/github.com/plimble/mage/install && \
  curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh && \
  mkdir -p ~/.ssh && \
  chmod 700 ~/.ssh && \
  ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
  ssh-keyscan github.com >> ~/.ssh/known_hosts && \
  ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts && \
  chmod 644 ~/.ssh/known_hosts
