FROM node:11

ARG KUBECTL_VERSION=v1.10.3
ARG HELM_VERSION=v2.9.1
ARG GOLANG_VERSION=1.12.3

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	openssh-client \
	gzip \
	tar \
	python-dev \
	git

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
	g++ \
	gcc \
	libc6-dev \
	make \
	pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION ${GOLANG_VERSION}

RUN set -eux; \
	\
	# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
	amd64) goRelArch='linux-amd64'; goRelSha256='3924819eed16e55114f02d25d03e77c916ec40b7fd15c8acb5838b63135b03df' ;; \
	armhf) goRelArch='linux-armv6l'; goRelSha256='efce59fac5ebc7302263ca1093fe2c3252c1b936f5b1ae08afc328eea0403c79' ;; \
	arm64) goRelArch='linux-arm64'; goRelSha256='4deb7f3b90d03f71f5cac3654e0e1f9cb46c45b85c5475510222b958e4ea2ed6' ;; \
	i386) goRelArch='linux-386'; goRelSha256='67599ae0788ed88260531d4be4293cb8f5199e5c7e06d30c6bd95eb54f014be7' ;; \
	ppc64el) goRelArch='linux-ppc64le'; goRelSha256='8bd04e742be8ed3f7f6fd2c78e2303be2ee70709cdc28758f101765a5e7d6dc1' ;; \
	s390x) goRelArch='linux-s390x'; goRelSha256='102fe607818ba21b9853ddfa3b1225b2af802010af3a032c6487144fbb7f3521' ;; \
	*) goRelArch='src'; goRelSha256='5c507abe8818429d74ebb650a4155d36bc3f9a725e59e76f5d6aca9690be2373'; \
	echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; \
	esac; \
	\
	url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
	wget -O go.tgz "$url"; \
	echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ "$goRelArch" = 'src' ]; then \
	echo >&2; \
	echo >&2 'error: UNIMPLEMENTED'; \
	echo >&2 'TODO install golang-any from jessie-backports for GOROOT_BOOTSTRAP (and uninstall after build)'; \
	echo >&2; \
	exit 1; \
	fi; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

ENV KUBE_LIB=v1

RUN set -x && \
	node -v && \
	go version && \
	go env && \
	mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" && \
	curl -fSL "https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz" -o helm.tar.gz && \
	tar -xzvf helm.tar.gz && \
	mv linux-amd64/helm /usr/local/bin/helm && \
	rm -rf linux-amd64 helm.tar.gz && \
	helm version -c && \
	curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
	mv kubectl /usr/local/bin/ && \
	chmod +x /usr/local/bin/kubectl && \
	curl -O https://bootstrap.pypa.io/get-pip.py && \
	python get-pip.py && \
	pip --version && \
	mkdir -p ~/.ssh && \
	chmod 700 ~/.ssh && \
	ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
	ssh-keyscan github.com >> ~/.ssh/known_hosts && \
	ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts && \
	chmod 644 ~/.ssh/known_hosts

ENV TOOL=v1

RUN go get -u github.com/jteeuwen/go-bindata/... && \
	go get -u github.com/onedaycat/zamus/zamus && \
	zamus --version && \
	go get -u github.com/onedaycat/vtlgen/vtlgen && \
	go get -u github.com/onedaycat/gqlscalars/gqlscalars && \
	go get -u github.com/plimble/mage/... && \
	$GOPATH/src/github.com/plimble/mage/install && \
	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh && \
	pip install awscli && \
	aws --version && \
	npm install -g @onedaycat/gqlimport && \
	npm install -g serverless && \
	sls version && \
	npm install -g firebase-tools && \
	firebase --version


WORKDIR $GOPATH
