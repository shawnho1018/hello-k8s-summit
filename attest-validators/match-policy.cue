import "time"

#schema: {
    builder: {
        id: 
    }
}
// The predicateType field must match this string
predicateType: "cosign.sigstore.dev/attestation/v1"

// The predicate must match the following constraints.
predicate: {
    builder:id: "https://cloudbuild.googleapis.com/GoogleHostedWorker@v0.3"
    
}
