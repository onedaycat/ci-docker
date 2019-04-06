FROM node:11

ARG KUBECTL_VERSION=v1.10.3
ARG HELM_VERSION=v2.9.1
ARG GOLANG_VERSION=1.12.2

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
	amd64) goRelArch='linux-amd64'; goRelSha256='f28c1fde8f293cc5c83ae8de76373cf76ae9306909564f54e0edcf140ce8fe3f' ;; \
	armhf) goRelArch='linux-armv6l'; goRelSha256='38d92116cd8c408e995972ff7fb0b6453c4f2214bde602d1772bd88f9d4d5c60' ;; \
	arm64) goRelArch='linux-arm64'; goRelSha256='598558fe54bbdce8b676f81e37f514dd70b8fc1377086658ae6e836480e900eb' ;; \
	i386) goRelArch='linux-386'; goRelSha256='3005a7937ff2be7ea9badd416cc37dfe2ff589d3a311f1685de0a805e45455b6' ;; \
	ppc64el) goRelArch='linux-ppc64le'; goRelSha256='62be1d5f38e322edc21de0debd3051247faff59890c343a7f2173c15098dbd35' ;; \
	s390x) goRelArch='linux-s390x'; goRelSha256='a41b0b11f5e34c3cccd7619bddf79a6d4b94bcbd2160fefcdf25f0afe87cad0a' ;; \
	*) goRelArch='src'; goRelSha256='af992580a4a609309c734d46fd4374fe3095961263e609d9b017e2dffc3b7b58'; \
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
