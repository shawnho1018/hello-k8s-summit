#!/bin/bash
export REPO_NAME="asia-east1-docker.pkg.dev/shawn-demo-2022/image-repos"
export IMAGE_NAME_IN_HASH="hello-k8s-summit@sha256:029ab9e49e1d6c17902c3b88de8084f6b989d56bf41e73ad97f4036af8acb13d"
export IMAGE="$REPO_NAME/$IMAGE_NAME_IN_HASH"
export BAD_IMAGE="nginx:latest"

kubectl create ns dev
kubectl label ns dev policy.sigstore.dev/include=true

read -p "Press any key to deploy a signed image in dev namespace"
kubectl run good-tester --image ${IMAGE} -n dev

kubectl wait --for=condition=Ready pod/good-tester -n dev

read -p "Press any key to deploy a bad image in dev namespace"
kubectl run bad-tester --image ${BAD_IMAGE} -n dev

read -p "Press any key to clean up"
kubectl delete pod good-tester -n dev
