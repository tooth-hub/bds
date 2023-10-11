#! /usr/bin/env bash

# $1 should be in form x.y.z.w
if [[ ! $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid version number: $BDS_VERSION"
    exit 1
fi

# Set $BDS_VERSION and $TOOTH_VERSION
BDS_VERSION=$1 # x.y.z.w
TOOTH_VERSION=$(echo $BDS_VERSION | cut -d. -f1-3) # x.y.z

# Read tooth.template.json into memory
TOOTH_TEMPLATE=$(cat tooth.template.json)

# Replace every <BDS_VERSION> with $BDS_VERSION and every <TOOTH_VERSION> with $TOOTH_VERSION
TOOTH_TEMPLATE=${TOOTH_TEMPLATE//<BDS_VERSION>/$BDS_VERSION}
TOOTH_TEMPLATE=${TOOTH_TEMPLATE//<TOOTH_VERSION>/$TOOTH_VERSION}

# Check if release/$BDS_VERSION already exists
if git rev-parse --verify release/$TOOTH_VERSION >/dev/null 2>&1; then
    echo "release/$TOOTH_VERSION already exists"
    exit 1
fi

# Create release/$BDS_VERSION
git checkout -b release/$TOOTH_VERSION release/base

# Write tooth.json
echo "$TOOTH_TEMPLATE" > tooth.json

# Commit and push
git add tooth.json
git commit -m "Release $BDS_VERSION"
git tag -a $BDS_VERSION -m "Release $BDS_VERSION"
git push origin release/$TOOTH_VERSION
