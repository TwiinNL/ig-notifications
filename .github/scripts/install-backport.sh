#!/usr/bin/env bash
# The published hl7.fhir.uv.subscriptions-backport.r4 package has an empty .index.json, so the
# publisher finds none of its resources. Without the index file, the publisher rebuilds it.
# See known-issues.md. Always installs from a fresh download: checks the pinned sha-256 (fails
# on a mismatch), replaces whatever is in the package cache (also a restored cache entry) and
# removes the index file. Run after SUSHI, in CI and locally.
set -euo pipefail

cache="${FHIR_PACKAGE_CACHE:-$HOME/.fhir/packages}"
name=hl7.fhir.uv.subscriptions-backport.r4
version=1.1.0
sha=083c7b36df03d26aedabaddd1feaee14771e8b62214844244c5db2a83c1343ea
url="https://packages.fhir.org/$name/$version"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -sSfL -o "$tmp/package.tgz" "$url"
actual="$(shasum -a 256 "$tmp/package.tgz" | cut -d' ' -f1)"
if [ "$actual" != "$sha" ]; then
  echo "::error::$name#$version: sha-256 $actual, expected $sha ($url)" >&2
  exit 1
fi

dir="$cache/$name#$version"
rm -rf "$dir"
mkdir -p "$dir"
tar xzf "$tmp/package.tgz" -C "$dir"
rm "$dir/package/.index.json"
echo "Installed $name#$version without .index.json (sha-256 $sha)"
