#!/bin/bash
set -euo pipefail

BUILDER_REPOSITORY="slsa-framework/slsa-github-generator"
BUILDER_TAG="bdd89e60dc5387d8f819bebc702987956bcd4913"

RELEASE_LIST=$(gh release -R "$BUILDER_REPOSITORY" -L 50 list)
while read -r line; do
    TAG=$(echo "$line" | cut -f1)
    BRANCH=$(gh release -R "$BUILDER_REPOSITORY" view "$TAG" --json targetCommitish --jq '.targetCommitish')
    if [[ "$BRANCH" != "main" ]]; then
        continue
    fi
    COMMIT=$(gh api /repos/"$BUILDER_REPOSITORY"/git/ref/tags/"$TAG" | jq -r '.object.sha')
    echo "COMMIT: $COMMIT"
    if [[ "$COMMIT" == "$BUILDER_TAG" ]]; then
        RELEASE_TAG="$TAG"
        echo "Found tag $BUILDER_TAG match at tag $TAG and commit $COMMIT"
        break
    fi
done <<<"$RELEASE_LIST"
