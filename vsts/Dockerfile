FROM microsoft/vsts-agent:ubuntu-16.04-docker-17.06.0-ce

ARG GO_VERSION=1.11.2
ARG KUBECTL_VERSION=v1.10.3
ARG RANCHER_CLI_VERSION=v2.0.4
ARG HELM_VERSION=v2.9.1
ARG NODE_VERSION=11.1.0

# Install basic command-line utilities
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  curl \
  dnsutils \
  file \
  ftp \
  iproute2 \
  iputils-ping \
  locales \
  openssh-client \
  sudo \
  telnet \
  time \
  unzip \
  wget \
  zip \
  tzdata \
  rsync \
  && rm -rf /var/lib/apt/lists/*

# Setup the locale
ENV LANG en_US.UTF-8
ENV LC_ALL $LANG
RUN locale-gen $LANG \
  && update-locale

# Install essential build tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

# Install Azure CLI (instructions taken from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
  | tee /etc/apt/sources.list.d/azure-cli.list \
  && curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-transport-https \
  azure-cli \
  && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -sL https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz -o go${GO_VERSION}.linux-amd64.tar.gz \
  && mkdir -p /usr/local/go \
  && tar -C /usr/local/go -xzf go${GO_VERSION}.linux-amd64.tar.gz --strip-components=1 go \
  && rm go${GO_VERSION}.linux-amd64.tar.gz \
  && mkdir -p /root/go/src \
  && mkdir -p /root/go/bin

ENV GOPATH=/root/go
ENV GOROOT=/usr/local/go
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin:/root/go/bin
ENV GO111MODULE=auto

# Install Helm
RUN curl -fSL "https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz" -o helm.tar.gz && \
  tar -xzvf helm.tar.gz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  rm -rf linux-amd64 helm.tar.gz && \
  helm version -c

# Install Rancher
RUN curl -fSL "https://releases.rancher.com/cli/${RANCHER_CLI_VERSION}/rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz" -o rancher.tar.gz && \
  tar -xzvf rancher.tar.gz && \
  mv rancher-${RANCHER_CLI_VERSION}/rancher /usr/local/bin/rancher && \
  rm -rf rancher-${RANCHER_CLI_VERSION} rancher.tar.gz && \
  rancher -v

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
  mv kubectl /usr/local/bin/ && \
  chmod +x /usr/local/bin/kubectl && \
  kubectl version --client

# Install Nodejs
RUN curl -L https://git.io/n-install | bash -s -- -y ${NODE_VERSION}
ENV PATH $PATH:/root/n/bin

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
  sudo apt-get update && sudo apt-get install -y --no-install-recommends yarn && \
  rm -rf /var/lib/apt/lists/* && \
  yarn -v

# Install Dep and go-bindata
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh && \
  go get -u github.com/jteeuwen/go-bindata/...

# Install Serverless
RUN npm config set user 0 && \
  npm config set unsafe-perm true && \
  npm install -g serverless
