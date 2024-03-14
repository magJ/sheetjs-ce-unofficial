#!/bin/sh

set -euo
cd "$(dirname "$0")"

# Get the latest version number from the sheetjs package.json
source_version=$(jq -r '.version' < sheetjs/package.json)

latest_published=$(cat latest_published.txt)

# version comparision function from https://stackoverflow.com/a/37939589/1544715
version() { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

if [ "$(version "$source_version")" -gt "$(version "$latest_published")" ]; then
  echo "Source version($source_version) newer than latest published version($latest_published)"
else
  echo "Source version is not newer than latest published version"
fi

echo "$source_version" > latest_published.txt

cd sheetjs
npm publish
cd ..
