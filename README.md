# ig-notifications

FHIR R4 implementation guide for the technical specification of TA Notifications, part of the technical core of the Twiin Afsprakenstelsel (TA Notifications 0.9 (draft)). It is based on the HL7 FHIR Subscriptions R5 Backport IG 1.1.0 (STU 1.1).

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

## Release 0.1.0

The IG refers to "TA Notifications 0.9 (draft)" in `index.md` and this README, without a link.

- TODO: link "TA Notifications 0.9" in `index.md` and this README in a patch release, once 0.9 is published.

`releaseLabel` is "Draft – normative only when referenced by the Twiin afsprakenstelsel". `publication-request.json` is for the first publication (`-go-publish` to `ig/` of TwiinNL/fhir); publishing itself is a separate step.

## OIDs

This IG deliberately has no OIDs. The resulting warnings and hints from the publisher are accepted.

## Build

```sh
./_updatePublisher.sh   # download/update the IG Publisher
sushi build .
./_genonce.sh -no-sushi # output in output/ (see output/qa.html)
```

Requires Java, Node (SUSHI) and Jekyll. The template is set in `ig.ini`, not in `sushi-config.yaml`: SUSHI 3.20.1 reports the `template` property as no longer supported.

The template is pinned to `fhir2.base.template#0.1.0`. `fhir.base.template` is no longer supported and the IG Publisher will refuse IGs that depend on it, see the [FHIR security notice of 17 March 2026](https://fhir.org/guides/security-notices/2026-03-npm-dependencies.html). `fhir2.base.template` builds all pages into `output/en/`; the pages in the root of `output/` are redirect stubs. This template version has two bugs, worked around in this repository: see [known-issues.md](known-issues.md).

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

`.github/scripts/check-qa.py` reads the errors from two files. `output/qa.xml` is a FHIR Bundle of OperationOutcomes written by the publisher; it is structured (severity, message and expression as separate elements), and each error becomes one line `<location>: <message>`, with the issue's `expression` as location (file name if there is none). `output/qa.txt` also lists the errors of the HTML check (for example the WCAG heading check on the generated pages), which `qa.xml` does not contain (`qa.json` only counts them); each `ERROR:` line becomes one line `<location>: <message>`, with the absolute path of `output/` replaced by `output/`. Every line must match a line in `known-errors.txt` exactly. Matching is on text and location, not on count. As a cross-check the script requires the errors of both files, counted once when both list them, to equal `errs` in `output/qa.json`, and fails otherwise.

The step "Test language redirect" runs `node test/lang-redirects.test.js` after the build: it checks that the redirect script in `output/` is our override of the template file and that browsers with language `nl`, `nl-NL`, `de`, `en` and `en-US` are all sent to `en/<page>`, with query string and fragment kept. The override (`input/images/assets/js/lang-redirects.js`) is a source file of the IG, so every build from this repository applies it, including the build for publication with `-go-publish`; that build has not been run for this change, so check `output/assets/js/lang-redirects.js` (and the copy in `output/en/`) before publishing. See [known-issues.md](known-issues.md).

Neither file's layout is documented as far as I could verify; both were inspected with IG Publisher 3.0.0, which is why the CI pins that version (`PUBLISHER_VERSION` in the workflow). On every publisher update, re-check that `qa.xml` and `qa.txt` together still list the same errors as `qa.html`. Entries in `known-errors.txt` that no longer occur are reported as a notice.

## License

- IG content (everything in `input/`, including FSH): CC BY-SA 4.0 (SPDX: `CC-BY-SA-4.0`), see [LICENSE](LICENSE).
- Code (workflows, own scripts): TBD.
- `_updatePublisher.*` and `_genonce.*` are copied unmodified from [HL7/ig-publisher-scripts](https://github.com/HL7/ig-publisher-scripts). The license of that repository is unknown; clarify with HL7 before publishing.
