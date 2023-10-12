#! /usr/bin/env bash

# Usage release <BDS_VERSION>
release() {
    git reset --hard
    git checkout -b release $(git rev-list --max-parents=0 HEAD)

    # Set $BDS_VERSION and $TOOTH_VERSION
    BDS_VERSION=$1 # x.y.z.w
    TOOTH_VERSION=$(echo $BDS_VERSION | cut -d. -f1-3) # x.y.z

    # Replace every <BDS_VERSION> with $BDS_VERSION and every <TOOTH_VERSION> with $TOOTH_VERSION
    TOOTH_CONTENT=$TOOTH_TEMPLATE
    TOOTH_CONTENT=${TOOTH_CONTENT//<BDS_VERSION>/$BDS_VERSION}
    TOOTH_CONTENT=${TOOTH_CONTENT//<TOOTH_VERSION>/$TOOTH_VERSION}

    # Write tooth.json
    echo "$TOOTH_CONTENT" > tooth.json

    # Commit and push
    git add tooth.json
    git commit -m "Release $TOOTH_VERSION"
    git tag v$TOOTH_VERSION

    # Clean up
    git checkout main
    git branch -D release
}

TOOTH_TEMPLATE=$(cat tooth.template.json)
VERSIONS=$(cat versions.txt)

# Remove all tags
git tag -l | xargs git tag -d
git push --tags --prune origin

# For each line of versions.txt, run release()
for VERSION in $VERSIONS; do
    release $VERSION
done

git push --tags origin
