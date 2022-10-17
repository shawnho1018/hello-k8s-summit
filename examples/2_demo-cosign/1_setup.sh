#!/bin/bash
export NS="cosign-system"
export secret_name="cosign-secret"
# Generate Cosign Key/PUB/PASSWORD
cosign generate-key-pair k8s://kube-system/${secret_name}
pub_key=$(kubectl get secret ${secret_name} -n kube-system -o jsonpath='{.data.cosign\.pub}')

# install policy-controller helm chart
helm repo add sigstore https://sigstore.github.io/helm-charts
helm repo update
kubectl create namespace ${NS}
helm install policy-controller -n ${NS} sigstore/policy-controller --devel

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=policy-controller -n ${NS}

# Provide Public Key for Policy Controller
cat << EOF | kubectl apply -f -
apiVersion: v1
data:
  cosign.pub: ${pub_key}
immutable: true
kind: Secret
metadata:
  annotations:
  name: mysecret
  namespace: ${NS}
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
