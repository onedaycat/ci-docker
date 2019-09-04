FROM golang:1.13.0-alpine

ENV LAST_UPDATE=2019-08-19-1
ENV TERRAFORM_VERSION=0.12.6
ENV CGO_ENABLED=0

RUN apk update && apk add --no-cache \
  curl \
  python \
  py-pip \
  openssh \
  git \
  nodejs \
  npm \
  yarn

RUN set -x && \
  ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
  python -V && \
  pip --version && \
  node -v && \
  npm -v && \
  yarn -v && \
  go version && \
  go env && \
  mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" && \
  mkdir -p ~/.ssh && \
  chmod 700 ~/.ssh && \
  ssh-keyscan gitlab.com >> ~/.ssh/known_hosts && \
  ssh-keyscan github.com >> ~/.ssh/known_hosts && \
  ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts && \
  chmod 644 ~/.ssh/known_hosts && \
  go get -u github.com/jteeuwen/go-bindata/... && \
  go get -u github.com/plimble/mage/... && \
  $GOPATH/src/github.com/plimble/mage/install && \
  pip install awscli && \
  aws --version && \
  npm install -g firebase-tools && \
  firebase --version && \
  curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
  rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  terraform -v && \
  git config --global url."git@github.com:".insteadOf "https://github.com/" && \
  git config --global url."git@gitlab.com:".insteadOf "https://gitlab.com/" && \
  git config --global url."git@bitbucket.org:".insteadOf "https://bitbucket.org/" && \
  apk --purge -v del py-pip && \
  rm -rf /var/cache/apk/*

COPY .terraformrc /root/.terraformrc

CMD ["bin/sh"]
