#!/bin/bash
DEMO_FOLDER=$(pwd)
# Use skaffold build with cloudbuild profile to get have the image signed for SLSA-L3
pushd ../../
skaffold build -p cloudbuild --file-output $DEMO_FOLDER/image.json
popd
IMAGE=$(cat image.json | jq -r '.builds[0].tag' | sed 's/\:latest//g')

# Retrieve the provenance.json
gcloud artifacts docker images describe ${IMAGE} --format json --show-provenance > provenance.json
SOURCE_URI=$(cat provenance.json | jq -r '.provenance_summary.provenance[0].build.intotoStatement.slsaProvenance.materials[0].uri')

# Verify Image
./slsa-verifier verify-image "$IMAGE" \
--provenance-path provenance.json \
--source-uri ${SOURCE_URI} \
--builder-id=https://cloudbuild.googleapis.com/GoogleHostedWorker

kubectl run test-pod --image ${IMAGE}

