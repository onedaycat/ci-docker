FROM node:11

ARG KUBECTL_VERSION=v1.10.3
ARG HELM_VERSION=v2.9.1
ARG GOLANG_VERSION=1.12

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
	amd64) goRelArch='linux-amd64'; goRelSha256='750a07fef8579ae4839458701f4df690e0b20b8bcce33b437e4df89c451b6f13' ;; \
	armhf) goRelArch='linux-armv6l'; goRelSha256='ea0636f055763d309437461b5817452419411eb1f598dc7f35999fae05bcb79a' ;; \
	arm64) goRelArch='linux-arm64'; goRelSha256='b7bf59c2f1ac48eb587817a2a30b02168ecc99635fc19b6e677cce01406e3fac' ;; \
	i386) goRelArch='linux-386'; goRelSha256='3ac1db65a6fa5c13f424b53ee181755429df0c33775733cede1e0d540440fd7b' ;; \
	ppc64el) goRelArch='linux-ppc64le'; goRelSha256='5be21e7035efa4a270802ea04fb104dc7a54e3492641ae44632170b93166fb68' ;; \
	s390x) goRelArch='linux-s390x'; goRelSha256='c0aef360b99ebb4b834db8b5b22777b73a11fa37b382121b24bf587c40603915' ;; \
	*) goRelArch='src'; goRelSha256='09c43d3336743866f2985f566db0520b36f4992aea2b4b2fd9f52f17049e88f2'; \
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
	npm install -g serverless && \
	npm install -g @onedaycat/gqlimport && \
	curl -O https://bootstrap.pypa.io/get-pip.py && \
	python get-pip.py && \
	pip --version && \
	pip install awscli && \
	aws --version && \
	mkdir -p ~/.ssh && \
	chmod 700 ~/.ssh && \
	ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
	ssh-keyscan github.com >> ~/.ssh/known_hosts && \
	ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts && \
	chmod 644 ~/.ssh/known_hosts

ENV LIB=v1

RUN go get -u github.com/jteeuwen/go-bindata/... && \
	go get -u github.com/onedaycat/zamus/zamus && \
	go get -u github.com/onedaycat/vtlgen/vtlgen && \
	go get -u github.com/onedaycat/gqlscalars/gqlscalars && \
	go get -u github.com/plimble/mage/... && \
	$GOPATH/src/github.com/plimble/mage/install && \
	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh && \
	npm install -g serverless

WORKDIR $GOPATH
