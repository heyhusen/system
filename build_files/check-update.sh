#!/bin/bash

set -ouex pipefail

CHANGELOG="CHANGELOG.md"

# Step 1: Get list of available updates
updates=$(dnf check-update --refresh \
    | awk '/^[[:alnum:]].* / {print "- " $1 " " $2}')
if [[ -z "$updates" ]]; then
    echo "No updates found."
    exit 0
fi

# Step 2: Extract latest version number from CHANGELOG
latest_version=$(grep -m1 -Po '(?<=## \[)[0-9]+\.[0-9]+\.[0-9]+' "$CHANGELOG")

# Step 3: Determine new version
if [[ -z "$latest_version" ]]; then
    # No version found → start at 42.0.0
    new_version="42.0.0"
else
    # Increment minor version (x.y.z → x.(y+1).0)
    IFS='.' read -r major minor patch <<< "$latest_version"
    new_minor=$((minor + 1))
    new_version="$major.$new_minor.0"
fi

# Step 4: Prepare updated changelog
tmpfile=$(mktemp)

awk -v updates="$updates" -v new_version="$new_version" -v today="$(date +%F)" '
    BEGIN {unreleased_done=0}
    NR==1 {print $0; next}  # Keep first line as is

    /^## \[Unreleased\]/ && !unreleased_done {
        print "## [Unreleased]"
        print ""
        print "## [" new_version "] - " today
        print ""
        print "### Changed"
        print ""
        print updates
        print ""
        unreleased_done=1
        next
    }
    {print $0}
' "$CHANGELOG" > "$tmpfile" && mv "$tmpfile" "$CHANGELOG"

echo "Changelog updated: bumped to version $new_version and added updates \
    under Unreleased."
