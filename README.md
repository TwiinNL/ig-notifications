# ig-notifications

FHIR R4 implementation guide for the technical specification of TA Notifications, part of the technical core of the Twiin Afsprakenstelsel. It is based on the HL7 FHIR Subscriptions R5 Backport IG 1.1.0 (STU 1.1).

- Package id: `nl.twiin.fhir.r4.notifications`
- Canonical: https://fhir.twiin.nl/ig/notifications
- FHIR version: 4.0.1
- Version: 0.1.0 (draft)
- Publisher: Twiin
- Dependencies: `hl7.fhir.uv.subscriptions-backport.r4#1.1.0` only

Built with [SUSHI](https://fshschool.org/docs/sushi/) and the HL7 IG Publisher.

## Dependency rules

- This IG must never depend on `nl.twiin.fhir.r4.workflow`.
- The version of the Backport IG must equal the one used in `nl.twiin.fhir.r4.workflow`, as long as Workflow does not depend on this IG.
- No dependency on `nl.twiin.fhir.r4.core` (still empty) and none on GF Adressering; add the latter only when an artifact refers to it.

## TODO before the first release

- TODO: fill in the TA Notifications version in the IG once TA Notifications 0.9 is published. The IG refers to "TA Notifications" without version until then.
- Pin the template version in `ig.ini` (currently `fhir.base.template#current`).

## Build

```sh
./_updatePublisher.sh   # download/update the IG Publisher
sushi build .
./_genonce.sh -no-sushi # output in output/ (see output/qa.html)
```

Requires Java, Node (SUSHI) and Jekyll. The template is set in `ig.ini`, not in `sushi-config.yaml`: SUSHI 3.20.1 reports the `template` property as no longer supported.

## Invariant tests

`test/invalid/` holds one invalid instance per invariant (file name = invariant key; `twiin-st-5b` is a second case for `twiin-st-5`). They are outside `input/` and not published. After a build, run:

```sh
test/validate-invalid.sh path/to/validator_cli.jar
```

The script validates each file against `output/package.tgz` and fails if the validator does not report the invariant named in the file name.

## CI

`.github/workflows/build.yml` runs on pull requests and pushes to `main`: SUSHI, download of IG Publisher 3.0.0 (pinned), build, upload of `output/` (including `qa.html`) as artifact `ig-output`.

The runner is pinned to `ubuntu-24.04` (not `ubuntu-latest`), so a change of the GitHub-hosted image does not alter the build unnoticed. Moving to a newer Ubuntu gets its own PR.

The build fails on every publisher error that is not listed in [known-errors.txt](known-errors.txt) (see [known-issues.md](known-issues.md)). The publisher exit code cannot be used for this: it exits with 0 on a build whose `qa.html` lists errors (see [ig-core](https://github.com/TwiinNL/ig-core)). Warnings and hints do not fail the build. Errors cannot be suppressed via `input/ignoreWarnings.txt`.

`.github/scripts/check-qa.py` reads the individual errors from `output/qa.xml`, a FHIR Bundle of OperationOutcomes written by the publisher. Chosen over the alternatives because it is structured (severity, message and expression as separate elements): `qa.txt` and `qa-eslintcompact.txt` are text for humans, and they carry absolute local paths or no location. Each error becomes one line `<location>: <message>`, with the issue's `expression` as location (file name if there is none), and must match a line in `known-errors.txt` exactly. Matching is on text and location, not on count. As a cross-check the script requires the number of errors in `qa.xml` to equal `errs` in `output/qa.json`, and fails otherwise.

Neither file's layout is documented as far as I could verify; both were inspected with IG Publisher 3.0.0, which is why the CI pins that version (`PUBLISHER_VERSION` in the workflow). On every publisher update, re-check that `qa.xml` still lists the same errors as `qa.html`. Entries in `known-errors.txt` that no longer occur are reported as a notice.

## License

- IG content (everything in `input/`, including FSH): CC BY-SA 4.0 (SPDX: `CC-BY-SA-4.0`), see [LICENSE](LICENSE).
- Code (workflows, own scripts): TBD.
- `_updatePublisher.*` and `_genonce.*` are copied unmodified from [HL7/ig-publisher-scripts](https://github.com/HL7/ig-publisher-scripts). The license of that repository is unknown; clarify with HL7 before publishing.
