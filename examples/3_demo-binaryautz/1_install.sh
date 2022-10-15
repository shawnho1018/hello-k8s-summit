#!/bin/bash
export PROJECT_ID="shawn-demo-2022"
export CLUSTER="k8s-summit"
export ZONE="asia-east1-a"

# Enable GKE's Binary Authorization
gcloud container clusters update ${CLUSTER} --zone ${ZONE} --binauthz-evaluation-mode=PROJECT_SINGLETON_POLICY_ENFORCE
# Set Deployment Policy to Accept only CloudBuild's build (SLSA L3)
cat << EOF > policy.yaml
defaultAdmissionRule:
  evaluationMode: REQUIRE_ATTESTATION
  enforcementMode: DRYRUN_AUDIT_LOG_ONLY
  requireAttestationsBy:
    - projects/${PROJECT_ID}/attestors/built-by-cloud-build
globalPolicyEvaluationMode: ENABLE
name: projects/${PROJECT_ID}/policy
clusterAdmissionRules:
  ${ZONE}.${CLUSTER}:
    evaluationMode: REQUIRE_ATTESTATION
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
    requireAttestationsBy:
    - projects/${PROJECT_ID}/attestors/built-by-cloud-build
EOF

gcloud container binauthz policy import ./policy.yaml