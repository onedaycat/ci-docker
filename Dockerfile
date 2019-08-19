FROM node:11

ARG KUBECTL_VERSION=v1.10.3
ARG HELM_VERSION=v2.9.1
ARG GOLANG_VERSION=1.12.6

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl \
	openssh-client \
	gzip \
	tar \
	python-dev \
	git

RUN apt-get update && apt-get install -y --no-install-recommends \
	g++ \
	gcc \
	libc6-dev \
	make \
	pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.6

RUN set -eux; \
	\
	# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
	amd64) goRelArch='linux-amd64'; goRelSha256='dbcf71a3c1ea53b8d54ef1b48c85a39a6c9a935d01fc8291ff2b92028e59913c' ;; \
	armhf) goRelArch='linux-armv6l'; goRelSha256='0708fbc125e7b782b44d450f3a3864859419b3691121ad401f1b9f00e488bddb' ;; \
	arm64) goRelArch='linux-arm64'; goRelSha256='8f4e3909c74b4f3f3956715f32419b28d32a4ad57dbd79f74b7a8a920b21a1a3' ;; \
	i386) goRelArch='linux-386'; goRelSha256='7aaf25164a9ab5e1005c15535ed16ee122df50ac192c2d79b7940315c2b74f2c' ;; \
	ppc64el) goRelArch='linux-ppc64le'; goRelSha256='67eacb68c1e251c1428e588776c5a02e287a508e3d44f940d31d8ff5d57f0eef' ;; \
	s390x) goRelArch='linux-s390x'; goRelSha256='c14baa10b87a38e56f28a176fae8a839e9052b0e691bdc0461677d4bcedea9aa' ;; \
	*) goRelArch='src'; goRelSha256='c96c5ccc7455638ae1a8b7498a030fe653731c8391c5f8e79590bce72f92b4ca'; \
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

ENV KUBE_LIB=v2

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

ENV TOOL=v2
ENV TERRAFORM_VERSION=0.12.6

RUN go get -u github.com/jteeuwen/go-bindata/... && \
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
	firebase --version && \
	curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
	terraform -v && \
	git config --global url."git@github.com:".insteadOf "https://github.com/" && \
	git config --global url."git@gitlab.com:".insteadOf "https://gitlab.com/" && \
	git config --global url."git@bitbucket.org:".insteadOf "https://bitbucket.org/"


WORKDIR $GOPATH
