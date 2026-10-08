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
- Remove the placeholder artifact (`input/fsh/placeholder.fsh`, Questionnaire `twiin-placeholder`). R4 requires at least one `ImplementationGuide.definition.resource`, so an IG without artifacts cannot build without errors.

## Build

```sh
./_updatePublisher.sh   # download/update the IG Publisher
sushi build .
./_genonce.sh -no-sushi # output in output/ (see output/qa.html)
```

Requires Java, Node (SUSHI) and Jekyll. The template is set in `ig.ini`, not in `sushi-config.yaml`: SUSHI 3.20.1 reports the `template` property as no longer supported.

## CI

`.github/workflows/build.yml` runs on pull requests and pushes to `main`: SUSHI, download of IG Publisher 3.0.0 (pinned), build, upload of `output/` (including `qa.html`) as artifact `ig-output`.

The build fails on any error in the QA report. The publisher exit code cannot be used for this: it exits with 0 on a build whose `qa.html` lists errors (see [ig-core](https://github.com/TwiinNL/ig-core)). The check therefore reads `errs` from `output/qa.json`. Warnings and hints do not fail the build. Errors cannot be suppressed via `input/ignoreWarnings.txt`.

The `qa.json` layout is not documented as far as I could verify; the CI pins publisher 3.0.0 for that reason (`PUBLISHER_VERSION` in the workflow). On every publisher update, re-check that `errs` is still present and still counts the errors listed in `qa.html`.

## License

- IG content (everything in `input/`, including FSH): CC BY-SA 4.0 (SPDX: `CC-BY-SA-4.0`), see [LICENSE](LICENSE).
- Code (workflows, own scripts): TBD.
- `_updatePublisher.*` and `_genonce.*` are copied unmodified from [HL7/ig-publisher-scripts](https://github.com/HL7/ig-publisher-scripts). The license of that repository is unknown; clarify with HL7 before publishing.
