#! /usr/bin/env bash

TOOTH_TEMPLATE=$(cat tooth.template.json)
VERSIONS=$(cat versions.txt)

# For each line of versions.txt, run release()
for VERSION in $VERSIONS; do
    git reset --hard
    git checkout -b release $(git rev-list --max-parents=0 HEAD)

    # Set $BDS_VERSION and $TOOTH_VERSION
    BDS_VERSION=$VERSION # x.y.z.w
    TOOTH_VERSION=$(echo $BDS_VERSION | cut -d. -f1-3) # x.y.z

    # If $TOOTH_VERSION is already tagged, skip
    if git rev-parse v$TOOTH_VERSION >/dev/null 2>&1; then
        echo "Skipping $TOOTH_VERSION"
        git checkout main
        git branch -D release
        continue
    fi

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
done

git push --tags origin
