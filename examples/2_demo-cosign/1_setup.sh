#!/bin/bash
# install policy-controller helm chart
helm repo add sigstore https://sigstore.github.io/helm-charts
helm repo update
kubectl create namespace cosign-system
helm install policy-controller -n cosign-system sigstore/policy-controller --devel

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=policy-controller -n cosign-system

# Provide Public Key for Policy Controller
cat << EOF | kubectl apply -f -
apiVersion: v1
data:
  cosign.pub: LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFZURtL0d4MUJjc2NtZUV3SGxYMEovdS90aUNEUApZSWVwSkZyNzF4WjBUR0pnVy9FU3pwM3dmOTdMMEU5bW5LTHA1dHBGSkloVEVhKzNmeWFMclNtMUR3PT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==
immutable: true
kind: Secret
metadata:
  annotations:
  name: mysecret
  namespace: cosign-system
type: Opaque
EOF

# Deploy ClusterImagePolicy
cat << EOF | kubectl apply -f -
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: cloudbuild-attestor
spec:
  images:
  - glob: "**"
  authorities:
  - name: custom-key
    key:
      secretRef:
        name: mysecret
    attestations:
    - name: must-have-cosign-sigstore-sign
      predicateType: custom
      policy:
        data: |
          import "time"
          predicateType: "cosign.sigstore.dev/attestation/v1"
        type: cue
EOF
