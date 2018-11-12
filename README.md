# CI/CD Docker

### Docker hub

[onedaycat/ci](https://hub.docker.com/r/onedaycat/ci/)

### Tags

- [go (ci/go/Dockerfile)](https://github.com/onedaycat/ci-docker/blob/master/ci/go/Dockerfile)
- [node (ci/node/Dockerfile)](https://github.com/onedaycat/ci-docker/blob/master/ci/node/Dockerfile)
- [latest (go and node) (ci/Dockerfile)](https://github.com/onedaycat/ci-docker/blob/master/ci/Dockerfile)
- [vsts (vsts/Dockerfile)](https://github.com/onedaycat/ci-docker/blob/master/vsts/Dockerfile)

## Versions

```
DOCKER_VERSION=17.04.0-ce
KUBECTL_VERSION=v1.10.3
RANCHER_CLI_VERSION=v2.0.4
HELM_VERSION=v2.9.1
GOLANG_VERSION=1.11.2
NODE_VERSION=11.1.0
```

## Tools

- go
  - dep
  - go-bindata
- node
  - yarn
  - severless
  - aws-cli
- rancher
- kubectl
- helm
- docker

## VSTS Agent

```sh
docker run -d \
-e VSTS_ACCOUNT=<ACCOUNT> \
-e VSTS_TOKEN=<PERSONAL_TOKEN> \
-e VSTS_POOL=<POOL_NAME> \
-e VSTS_AGENT=<AGENT_NAME> \
-e VSTS_WORK='/var/vsts/$VSTS_AGENT' \
-v /var/vsts:/var/vsts \
-v /var/run/docker.sock:/var/run/docker.sock \
--net=host \
--name vsts-agent1 \
onedaycat/ci:vsts
```
