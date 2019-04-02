FROM node:11

ARG KUBECTL_VERSION=v1.10.3
ARG HELM_VERSION=v2.9.1
ARG GOLANG_VERSION=1.12.1

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
	amd64) goRelArch='linux-amd64'; goRelSha256='2a3fdabf665496a0db5f41ec6af7a9b15a49fbe71a85a50ca38b1f13a103aeec' ;; \
	armhf) goRelArch='linux-armv6l'; goRelSha256='ceac33f07f8fdbccd6c6f7339db33479e1be8c206e67458ba259470fe796dbf2' ;; \
	arm64) goRelArch='linux-arm64'; goRelSha256='10dba44cf95c7aa7abc3c72610c12ebcaf7cad6eed761d5ad92736ca3bc0d547' ;; \
	i386) goRelArch='linux-386'; goRelSha256='af74b6572dd0c133e5de121928616eab60a6252c66f6d9b15007c82207416a2c' ;; \
	ppc64el) goRelArch='linux-ppc64le'; goRelSha256='e1258c81f420c88339abf40888423904c0023497b4e9bbffac9ee484597a57d3' ;; \
	s390x) goRelArch='linux-s390x'; goRelSha256='a9b8f49be6b2083e2586c2ce8a2a86d5dbf47cca64ac6195546a81c9927f9513' ;; \
	*) goRelArch='src'; goRelSha256='0be127684df4b842a64e58093154f9d15422f1405f1fcff4b2c36ffc6a15818a'; \
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

ENV TOOL=v5

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
