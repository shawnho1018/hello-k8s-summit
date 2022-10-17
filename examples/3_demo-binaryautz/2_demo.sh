#!/bin/bash
export BAD_IMAGE="nginx:latest"

DEMO_FOLDER=$(pwd)
# Use skaffold build with cloudbuild profile to get have the image signed for SLSA-L3
pushd ../../
skaffold build -p cloudbuild --file-output $DEMO_FOLDER/image.json
popd
IMAGE=$(cat image.json | jq -r '.builds[0].tag' | sed 's/\:latest//g')

# Retrieve the provenance.json
gcloud artifacts docker images describe ${IMAGE} --format json --show-provenance > provenance.json
SOURCE_URI=$(cat provenance.json | jq -r '.provenance_summary.provenance[0].build.intotoStatement.slsaProvenance.materials[0].uri')

# Install slsa-verifier
curl https://github.com/slsa-framework/slsa-verifier/releases/download/v1.4.1-rc/slsa-verifier-linux-amd64 --output ./slsa-verifier
chmod +x ./slsa-verifier
# Validate the image with proper provenace and source-uri.
./slsa-verifier verify-image "$IMAGE" \
--provenance-path provenance.json \
--source-uri ${SOURCE_URI} \
--builder-id=https://cloudbuild.googleapis.com/GoogleHostedWorker

read -p "Press any key to deploy a signed image in dev namespace"
kubectl run good-tester --image ${IMAGE} 

kubectl wait --for=condition=Ready pod/good-tester

read -p "Press any key to deploy a bad image in dev namespace"
kubectl run bad-tester --image ${BAD_IMAGE}

read -p "Press any key to clean up"
kubectl delete pod good-tester
