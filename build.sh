#!/bin/sh

set -euo
cd "$(dirname "$0")"

# Get the latest version number from the sheetjs package.json
source_version=$(jq -r '.version' < sheetjs/package.json)

cd sheetjs
# build SheetJS from source
npm pack
cd ..

# Download the official release tarball
if ! curl -o "xlsx-${source_version}.tgz" -L "https://cdn.sheetjs.com/xlsx-${source_version}/xlsx-${source_version}.tgz"; then
    echo "Failed to download the official release tarball, for version ${source_version}"
    exit 1
fi

# Compare the official release tarball with the one we built to ensure they match
if ! pkgdiff "xlsx-${source_version}.tgz" "sheetjs/xlsx-${source_version}.tgz"; then
    echo "The official release tarball and the one we built do not match"
    exit 1
fi

# Change the package name and repo url
jq '.repository.url = "https://github.com/magJ/sheetjs-ce-unofficial"| .name="sheetjs-ce-unofficial"' < sheetjs/package.json > package.json.tmp
mv package.json.tmp sheetjs/package.json

# build SheetJS again, with the updated package.json
cd sheetjs
npm pack