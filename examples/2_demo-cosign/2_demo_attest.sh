#!/bin/bash
export IMAGE="asia-east1-docker.pkg.dev/shawn-demo-2022/image-repos/hello-k8s-summit@sha256:029ab9e49e1d6c17902c3b88de8084f6b989d56bf41e73ad97f4036af8acb13d"
export COSIGN_PASSWORD="demo-k8s-summit"

cosign attest --key cosign.key --predicate good-predicate.json ${IMAGE}
