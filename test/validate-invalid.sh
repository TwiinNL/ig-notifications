#!/usr/bin/env bash
# Validates every instance in test/invalid/ against the built IG package and checks
# that the validator reports the invariant named in the file name (twiin-st-5b -> twiin-st-5).
# Usage: test/validate-invalid.sh <path to validator_cli.jar>
# Requires a completed IG build (output/package.tgz). Not part of the published IG.
set -uo pipefail
jar="${1:?path to validator_cli.jar}"
dir="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$dir")"
out="$(mktemp -d)"
fail=0
for f in "$dir"/invalid/*.json; do
  name="$(basename "$f" .json)"
  key="$(sed -E 's/^(twiin-[a-z]+-[0-9]+).*/\1/' <<<"$name")"
  java -jar "$jar" "$f" -version 4.0.1 -ig "$root/output/package.tgz" \
    -output "$out/$name.json" > "$out/$name.log" 2>&1
  hits="$(python3 - "$out/$name.json" "$key" <<'PY'
import json, sys
oo = json.load(open(sys.argv[1]))
for i in oo.get("issue", []):
    t = i.get("details", {}).get("text", "")
    if sys.argv[2] + ":" in t or "(" + sys.argv[2] + ")" in t or t.startswith(sys.argv[2]):
        print(i["severity"] + ": " + t[:200])
PY
)"
  if [ -n "$hits" ]; then echo "OK   $name -> $hits"; else echo "FAIL $name: $key not reported"; fail=1; fi
done
exit $fail
