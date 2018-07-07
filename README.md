# CI/CD Docker


### VSTS Usage

```sh
docker run -d \
-e VSTS_ACCOUNT=<ACCOUNT> \
-e VSTS_TOKEN=<PERSONAL_TOKEN> \
-e VSTS_POOL=<POOL_NAME> \
-e VSTS_AGENT=<AGENT_NAME> \
-e VSTS_WORK='/var/vsts/$VSTS_AGENT' \
-v /var/vsts:/var/vsts \
-v /var/run/docker.sock:/var/run/docker.sock \
--name vsts-agent1 \
plimble/ci:vsts
```
