#!/bin/bash
export IMAGE="asia-east1-docker.pkg.dev/shawn-demo-2022/image-repos/hello-k8s-summit@sha256:029ab9e49e1d6c17902c3b88de8084f6b989d56bf41e73ad97f4036af8acb13d"
export COSIGN_PASSWORD="$(kubectl get secret mysecret -n default -o jsonpath='{.data.cosign\.password}' | base64 -d)"
kubectl get secret ${secret_name} -n kube-system -o jsonpath='{.data.cosign\.key}' | base64 -d > cosign.key
cosign attest --key cosign.key --predicate good-predicate.json ${IMAGE}
