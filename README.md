# ig-notifications

FHIR R4 implementation guide for the technical specification of TA Notifications, part of the technical core of the Twiin Afsprakenstelsel (TA Notifications 0.9 (draft)). It is based on the HL7 FHIR Subscriptions R5 Backport IG 1.1.0 (STU 1.1).

- Package id: `nl.twiin.fhir.r4.notifications`
- Canonical: https://fhir.twiin.nl/ig/notifications
- FHIR version: 4.0.1
- Version: 0.1.0-draft (working release, see [Release 0.1.0-draft](#release-010-draft))
- Publisher: Twiin
- Dependencies: `hl7.fhir.uv.subscriptions-backport.r4#1.1.0` only

Built with [SUSHI](https://fshschool.org/docs/sushi/) and the HL7 IG Publisher.

## Dependency rules

- This IG must never depend on `nl.twiin.fhir.r4.workflow`.
- The version of the Backport IG must equal the one used in `nl.twiin.fhir.r4.workflow`, as long as Workflow does not depend on this IG.
- No dependency on `nl.twiin.fhir.r4.core` (still empty) and none on GF Adressering; add the latter only when an artifact refers to it.

## Release 0.1.0-draft

The first publication is the working release `0.1.0-draft` (`mode: working` in `publication-request.json`), not milestone `0.1.0`. IG Publisher 3.0.0 crashes on a milestone publication: `IGReleaseRedirectionBuilder` requires its folder to be inside the website root, but `-go-publish` passes the milestone build output, which is outside it. Fixed upstream in [HL7/fhir-ig-publisher d64c08c](https://github.com/HL7/fhir-ig-publisher/commit/d64c08c) (8 October 2026), not yet in a release. See [known-issues.md](known-issues.md).

Consequence of a working release: only `https://fhir.twiin.nl/ig/notifications/0.1.0-draft/` holds the IG; the root of the canonical holds no copy and no redirects, and no version is marked current. Milestone `0.1.0`, with the same content, follows once a publisher release contains the fix.


The IG refers to "TA Notifications 0.9 (draft)" in `index.md` and this README, without a link.

- TODO: link "TA Notifications 0.9" in `index.md` and this README in a patch release, once 0.9 is published.

`releaseLabel` is "Draft – normative only when referenced by the Twiin afsprakenstelsel". `publication-request.json` is for the first publication (`-go-publish` to `ig/` of TwiinNL/fhir); publishing itself is a separate step.

## OIDs

This IG deliberately has no OIDs. The resulting warnings and hints from the publisher are accepted.

## Build

```sh
./_updatePublisher.sh   # download/update the IG Publisher
sushi build .
.github/scripts/install-template.sh   # twiin.base.template, see Template below
./_genonce.sh -no-sushi # output in output/ (see output/qa.html)
```

Requires Java, Node (SUSHI) and Jekyll. The template is set in `ig.ini`, not in `sushi-config.yaml`: SUSHI 3.20.1 reports the `template` property as no longer supported.

### Template

The IG is built with `twiin.base.template#0.1.1` ([TwiinNL/ig-template](https://github.com/TwiinNL/ig-template)), the Twiin house style on top of `fhir2.base.template#0.1.0`. The template is not on the FHIR package registry: it is the asset `twiin.base.template-0.1.1.tgz` of [release v0.1.1](https://github.com/TwiinNL/ig-template/releases/tag/v0.1.1), sha-256 `e95e60fa5b463cadd4ef34ad4b6c0dcee32fa05d02bfd649b4ff90960d22b123`. `.github/scripts/install-template.sh` downloads it, fails on a different sha-256, and unpacks it into `~/.fhir/packages/twiin.base.template#0.1.1`, where the publisher looks for it (it replaces what is there). Run it before `_genonce.sh`; `_genonce.sh` itself is the unmodified HL7 script and does not download templates. CI runs the same script (step "Install twiin.base.template"). A new template version means changing `ig.ini` and the version and sha-256 in the script together; the script fails if they differ. Version and sha-256 are part of the key of the package cache.

`fhir2.base.template#0.1.0`, the base of the template, is downloaded by the publisher and stays in `.github/fhir-packages.lock`. `fhir.base.template` is no longer supported: according to the [FHIR security notice of 17 March 2026](https://fhir.org/guides/security-notices/2026-03-npm-dependencies.html) the IG Publisher will refuse such IGs "at some stage in the near future", not yet. `fhir2.base.template` builds all pages into `output/en/`; the pages in the root of `output/` are redirect stubs.

The template fixes what this repository used to override: `lang-redirects.js` (redirect for non-English browsers), `fragment-pagebegin.html` (release label in the header) and the doubled `<h2 id="root">` on profile history pages. The tests of the template files themselves are in the template repository; `test/lang-redirects.test.js` and `test/release-label.test.js` only check the build output. Since 0.1.1 wide tables scroll in their own container on narrow screens. What the template does not fix is in [known-issues.md](known-issues.md).

## Invariant tests

`test/invalid/` holds one invalid instance per invariant (file name = invariant key; `twiin-st-5b` is a second case for `twiin-st-5`). They are outside `input/` and not published. After a build, run:

```sh
test/validate-invalid.sh path/to/validator_cli.jar
```

The script validates all files in one validator run (so the JVM and the package load once) against `output/package.tgz` and fails if the validator does not report the invariant named in the file name. A file that violates something other than an invariant has a `<name>.expect` next to it with a text the reported issue must contain. CI runs it after the build (step "Validate invalid examples") with validator_cli.jar 7.0.1, the core version of IG Publisher 3.0.0, and fails if an instance is not reported as expected.

## CI

`.github/workflows/build.yml` runs on pull requests and pushes to `main`: SUSHI, download of IG Publisher 3.0.0 (pinned), install of `twiin.base.template` (sha-256 checked), build, upload of `output/` (including `qa.html`) as artifact `ig-output`.

The runner is pinned to `ubuntu-24.04` (not `ubuntu-latest`), so a change of the GitHub-hosted image does not alter the build unnoticed. Moving to a newer Ubuntu gets its own PR.

The build fails on every publisher error that is not listed in [known-errors.txt](known-errors.txt) (see [known-issues.md](known-issues.md)). The publisher exit code cannot be used for this: it exits with 0 on a build whose `qa.html` lists errors (see [ig-core](https://github.com/TwiinNL/ig-core)). Warnings and hints do not fail the build. Errors cannot be suppressed via `input/ignoreWarnings.txt`.

After the QA check, the step "Download validator" fetches validator_cli.jar 7.0.1 (`VALIDATOR_VERSION`, sha-256 checked) and "Validate invalid examples" runs `test/validate-invalid.sh`; see [Invariant tests](#invariant-tests). Update the validator together with the publisher.

`.github/scripts/check-qa.py` reads the errors from two files. `output/qa.xml` is a FHIR Bundle of OperationOutcomes written by the publisher; it is structured (severity, message and expression as separate elements), and each error becomes one line `<location>: <message>`, with the issue's `expression` as location (file name if there is none). `output/qa.txt` also lists the errors of the HTML check (for example the WCAG heading check on the generated pages), which `qa.xml` does not contain (`qa.json` only counts them); each `ERROR:` line becomes one line `<location>: <message>`, with the absolute path of `output/` replaced by `output/`. Every line must match a line in `known-errors.txt` exactly. Matching is on text and location, not on count. As a cross-check the script requires the errors of both files, counted once when both list them, to equal `errs` in `output/qa.json`, and fails otherwise.

The Publication Request is under the same gate. The publisher checks `publication-request.json` against the built package and the package list at the canonical (`PublicationChecker`, IG Publisher 3.0.0) and writes the result only into the row "Publication Request" of `output/qa.html`, as HTML with an icon per message (`PublicationChecker.java:60-100` and `:490-499`, `ValidationPresenter.java:1116`); it is not in `qa.xml`, `qa.txt` or `errs` of `qa.json`. `check-qa.py` reads that row, and every error and every warning must be listed in `known-errors.txt` as `Publication Request: <message>`, or the build fails; information messages (such as "This IG has never been published") are ignored. A missing or unreadable row, or one without the summary of the request, also fails the build. The check fetches `package-list.json` from the canonical, so a network error there is reported as an error too. `test/check-qa.test.py` tests the parsing without a build (CI step "Test QA check").

The steps "Test language redirect" and "Test release label" run `node test/lang-redirects.test.js` and `node test/release-label.test.js` after the build. The first checks that the redirect script in `output/` and `output/en/` sends browsers with language `nl`, `nl-NL`, `de`, `en` and `en-US` to `en/<page>`, with query string and fragment kept; the second that every page in `output/en/` with the template header shows the release label. Both script and header come from `twiin.base.template`, so the tests check the build output only.

Neither file's layout is documented as far as I could verify; both were inspected with IG Publisher 3.0.0, which is why the CI pins that version (`PUBLISHER_VERSION` in the workflow). On every publisher update, re-check that `qa.xml` and `qa.txt` together still list the same errors as `qa.html`. Entries in `known-errors.txt` that no longer occur are reported as a notice.

### Package lock file

`.github/fhir-packages.lock` lists every package (`<id>#<version>`, sorted, one per line) that a build leaves in `~/.fhir/packages`. The last step, "Check package set against lock file" (`.github/scripts/check-package-set.sh`), fails when that set differs from the file, in either direction, and prints the diff. The file is also part of the key of the package cache, so a restored cache holds exactly the locked set.

If the build fails on that step:

1. Read the diff in the log. A package that moved (a floating dependency such as `latest`), a changed dependency in `sushi-config.yaml` or a new transitive package each show up as a changed line. Decide whether the change is intended; if not, pin the dependency instead of updating the lock.
2. If it is intended: replace the contents of `.github/fhir-packages.lock` with the list printed under "Packages in ~/.fhir/packages:" in the same log (only the package lines, not the header), and commit it with the change that caused it.
3. The new lock file gives a new cache key, so the next run downloads the packages once and saves them.

## License

- IG content (everything in `input/`, including FSH): CC BY-SA 4.0 (SPDX: `CC-BY-SA-4.0`), see [LICENSE](LICENSE).
- Code (workflows, own scripts): TBD.
- `_updatePublisher.*` and `_genonce.*` are copied unmodified from [HL7/ig-publisher-scripts](https://github.com/HL7/ig-publisher-scripts). The license of that repository is unknown; clarify with HL7 before publishing.
