#!/usr/bin/env bash
# Validates every instance in test/invalid/ against the built IG package and checks
# that the validator reports the invariant named in the file name (twiin-st-5b -> twiin-st-5).
# For a file that violates something other than an invariant (e.g. a fixed value), a file
# <name>.expect next to it holds a text that a reported issue must contain instead.
# One validator run covers all files (the JVM and package load once). With -output and several
# inputs, validator_cli 7.0.1 writes a Bundle with one OperationOutcome per input file; the
# file is named in the extension http://hl7.org/fhir/StructureDefinition/operationoutcome-file.
# A file without an OperationOutcome in the output counts as a failure.
# Usage: test/validate-invalid.sh <path to validator_cli.jar>
# Requires a completed IG build (output/package.tgz). Not part of the published IG.
set -uo pipefail
jar="${1:?path to validator_cli.jar}"
dir="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$dir")"
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

files=("$dir"/invalid/*.json)
[ -e "${files[0]}" ] || { echo "FAIL no instances in $dir/invalid"; exit 1; }

java -jar "$jar" "${files[@]}" -version 4.0.1 -ig "$root/output/package.tgz" \
  -output "$out/result.json" > "$out/validator.log" 2>&1
status=$?

python3 - "$out/result.json" "$status" "${files[@]}" <<'PY'
import json, os, re, sys
result, status, files = sys.argv[1], sys.argv[2], sys.argv[3:]
FILE_EXT = "http://hl7.org/fhir/StructureDefinition/operationoutcome-file"

outcomes = {}
try:
    with open(result) as fh:
        doc = json.load(fh)
    # One input file gives a bare OperationOutcome, several give a Bundle of them.
    found = [e["resource"] for e in doc["entry"]] if doc.get("resourceType") == "Bundle" else [doc]
    for oo in found:
        for ext in oo.get("extension", []):
            if ext.get("url") == FILE_EXT:
                outcomes[os.path.basename(ext["valueString"])] = oo
except (OSError, ValueError, KeyError) as e:
    print("FAIL validator output unusable (exit %s): %s" % (status, e))

fail = 0
for f in files:
    base = os.path.basename(f)
    name = base[:-len(".json")]
    key = re.sub(r"^(twiin-[a-z]+-[0-9]+).*", r"\1", name)
    expect = ""
    expect_file = os.path.join(os.path.dirname(f), name + ".expect")
    if os.path.isfile(expect_file):
        with open(expect_file) as fh:
            expect = fh.read().rstrip("\n")
    oo = outcomes.get(base)
    if oo is None:
        print("FAIL %s: not in validator output (skipped or validator failed)" % name)
        fail = 1
        continue
    hits = []
    for i in oo.get("issue", []):
        t = i.get("details", {}).get("text", "")
        if (expect and expect in t) or (not expect and (key + ":" in t or "(" + key + ")" in t or t.startswith(key))):
            hits.append(i["severity"] + ": " + t[:200])
    if hits:
        print("OK   %s -> %s" % (name, "\n".join(hits)))
    else:
        print("FAIL %s: %s not reported" % (name, expect or key))
        fail = 1
sys.exit(fail)
PY
rc=$?
[ $rc -ne 0 ] && { echo "--- validator log (tail) ---"; tail -n 20 "$out/validator.log"; }
exit $rc
