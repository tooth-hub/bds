#! /usr/bin/env bash

# Fetch the download link for the latest version of BDS
response=$(curl -s https://mc-bds-helper.vercel.app/api/latest)

# Extract the version number using regex
if [[ $response =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    version="${BASH_REMATCH[0]}"
else
    echo "Failed to extract version number from the response."
    exit 1
fi

echo "The latest versions is $version."

# Compare the last line of versions.txt with the latest version
if [[ $(tail -n 2 versions.txt | tr -d '\n') == $version ]]; then
    echo "The latest version is already downloaded."
    exit 0
fi
