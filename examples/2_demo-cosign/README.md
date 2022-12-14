# Image Attestation & Deployment Enforcement Lab
This lab demonstrates how to utilize [sigstore/cosign](https://github.com/sigstore/cosign) and [sigstore/policy-controller](https://github.com/sigstore/policy-controller) projects to demonstrate how to use cosign CLI to attest the image and how to validate the attestation in kubernetes cluster. 

## Pre-requisite
You must have the following resources before executing this lab.
* GKE cluster (any OSS K8s > 1.21 should work)
* Pre-install cosign CLI from [sigstore/cosign](https://github.com/sigstore/cosign) releases. 
* Has a newly built image in GCP's artifact repository. If not, run the following command in the project main folder.
``` bash
skaffold build --file-output image.json
```

## Steps
### Execute 1_setup.sh: 
This step would produce a cosign key-pair and a password in kubernetes cluster's specified namespace (default is in kube-system). After the secret is generated, we'll also produce a secret with only the public key and provide it to ClusterImagePolicy for further validate the attestation. A sample ClusterImagePolicy is provided with its public key assigned to use the secret, which is auto-generated by our 1_setup.sh secret. 

As for ClusterImagePolicy deep dive, please refer to [the documentation](https://docs.sigstore.dev/policy-controller/overview/#configuring-policy-controller-clusterimagepolicy) In our example, ClusterImagePolicy is specified to validate against all images (because spec.images.glob: "**") and the policy controller would also verify against Provenance's attestation. It must patch the predicate type: "cosign.sigstore.dev/attestation/v1". 

### Execute 2_demo_attest.sh
This step requires the image name & its hash tag as input variables. With those, the script would automatically be signed along with the good-predicate.json file which was pre populated. Cosign attest process normally requires to provide COSIGN_PASSWORD, generated by cosign's key generation process. By defining "COSIGN_PASSWORD" variable, the attest process could automatically be executed without administrator's interference. 

In the real service, this predicate should include the process steps, materials and products, which is normally produced by managed services (e.g. Github action or CloudBuild).

### Execute 3_demo_verify.sh
The last step show the final result by deploying a signed and a unsigned image. 