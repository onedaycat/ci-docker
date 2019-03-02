FROM node:11-alpine

ARG KUBECTL_VERSION=v1.10.3
ARG HELM_VERSION=v2.9.1
ARG GOLANG_VERSION=1.12

RUN apk update && \
	apk upgrade && \
	apk add --update --no-cache gcc tar gzip libc6-compat curl git openssh-client bash g++ ca-certificates python-dev

RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV GOLANG_VERSION ${GOLANG_VERSION}

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
	bash \
	gcc \
	musl-dev \
	openssl \
	go \
	; \
	export \
	# set GOROOT_BOOTSTRAP such that we can actually build Go
	GOROOT_BOOTSTRAP="$(go env GOROOT)" \
	# ... and set "cross-building" related vars to the installed system's values so that we create a build targeting the proper arch
	# (for example, if our build host is GOARCH=amd64, but our build env/image is GOARCH=386, our build needs GOARCH=386)
	GOOS="$(go env GOOS)" \
	GOARCH="$(go env GOARCH)" \
	GOHOSTOS="$(go env GOHOSTOS)" \
	GOHOSTARCH="$(go env GOHOSTARCH)" \
	; \
	# also explicitly set GO386 and GOARM if appropriate
	# https://github.com/docker-library/golang/issues/184
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
	armhf) export GOARM='6' ;; \
	x86) export GO386='387' ;; \
	esac; \
	\
	wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz"; \
	echo '09c43d3336743866f2985f566db0520b36f4992aea2b4b2fd9f52f17049e88f2 *go.tgz' | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	cd /usr/local/go/src; \
	./make.bash; \
	\
	rm -rf \
	# https://github.com/golang/go/blob/0b30cf534a03618162d3015c8705dd2231e34703/src/cmd/dist/buildtool.go#L121-L125
	/usr/local/go/pkg/bootstrap \
	# https://golang.org/cl/82095
	# https://github.com/golang/build/blob/e3fe1605c30f6a3fd136b561569933312ede8782/cmd/release/releaselet.go#L56
	/usr/local/go/pkg/obj \
	; \
	apk del .build-deps; \
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
	aws --version

RUN go get -u github.com/jteeuwen/go-bindata/... && \
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
	chmod 644 ~/.ssh/known_hosts && \
	npm install -g serverless

WORKDIR $GOPATH
