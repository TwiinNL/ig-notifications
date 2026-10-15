# Known issues

## Milestone publication crashes in IG Publisher 3.0.0

Applies to: IG Publisher 3.0.0, `-go-publish` with `mode: milestone` (or `technical-correction`).

After both publication builds succeed, the run stops with `java.lang.Error: The folder <temp>/ig-builds/<package>#<version>-milestone/output is not inside the website root folder <temp>/web-root/run-<date>` (`IGReleaseRedirectionBuilder.java:158`, called from `PublicationProcess.java:748`). The milestone build output is never inside the working web root, so every milestone publication fails. Observed in a trial run on 2026-10-09 against a copy of TwiinNL/fhir.

Fixed upstream in [HL7/fhir-ig-publisher d64c08c](https://github.com/HL7/fhir-ig-publisher/commit/d64c08c) ("Fix publication crash when building redirects for the milestone build output", 8 October 2026), not yet in a release. Workaround: publish `0.1.0-draft` and `0.1.1-draft` with `mode: working`; `0.1.0-draft` is removed from the site after `0.1.1-draft` is published. Publish a milestone with the same content once a publisher release contains the fix, and pin that version in CI.

## Backport IG declares FHIR 4.0.0

Applies to: IG Publisher 3.0.0, `hl7.fhir.uv.subscriptions-backport.r4#1.1.0`. Allowlisted in [known-errors.txt](known-errors.txt).

This IG is FHIR 4.0.1. The Backport package declares FHIR 4.0.0, both in `package.json` (`fhirVersions: ["4.0.0"]`) and in its `ImplementationGuide-hl7.fhir.uv.subscriptions-backport.json` (`fhirVersion: ["4.0.0"]`). The publisher therefore reports:

- Error, `ImplementationGuide/nl.twiin.fhir.r4.notifications`:
  `This IG is version 4.0.1, while the IG 'hl7.fhir.uv.subscriptions-backport.r4' is from version 4.0.0`

Related warnings (not allowlisted, warnings do not fail the build):

- `ImplementationGuide.dependsOn[2]: The ImplementationGuide is based on FHIR version 4.0.1 but package hl7.fhir.uv.subscriptions-backport.r4#1.1.0 is based on FHIR version 4.0.0. In general, this version mismatch should be avoided - some tools will try to make this work with variable degrees of success, but others will not even try`
- `ImplementationGuide.dependsOn[2]: The canonical URL http://hl7.org/fhir/uv/subscriptions-backport/ImplementationGuide/hl7.fhir.uv.subscriptions-backport doesn't point to an actual ImplementationGuide resource`

Decision: `fhirVersion` stays 4.0.1. Re-check when the publisher or the Backport version changes.

## Backport package has an empty index

Applies to: IG Publisher 3.0.0, `hl7.fhir.uv.subscriptions-backport.r4#1.1.0`. Worked around in CI, not allowlisted.

The published package contains `package/.index.json` with `"files": []` (checked in the tarball from packages.fhir.org). The publisher loads package resources through this index, finds none of the Backport StructureDefinitions, and stops with `Cannot find or generate snapshot for base definition (http://hl7.org/fhir/uv/subscriptions-backport/StructureDefinition/backport-subscription-notification-r4 ...)`. Without the file, the publisher rebuilds the index.

The CI step "Work around empty index of Backport package" puts the package in the cache and removes `.index.json`. For a local build, remove `~/.fhir/packages/hl7.fhir.uv.subscriptions-backport.r4#1.1.0/package/.index.json` once.

## Backport binds `type` to an R4B/R5 ValueSet

Applies to: IG Publisher 3.0.0, `hl7.fhir.uv.subscriptions-backport.r4#1.1.0`. Allowlisted in [known-errors.txt](known-errors.txt).

`backport-subscription-status-r4` binds `parameter:type.value[x]` to `http://hl7.org/fhir/ValueSet/subscription-notification-type`, which does not exist in FHIR R4. Twiin Subscription Status inherits the binding. Errors:

- `Parameters.parameter.value: The reference http://hl7.org/fhir/ValueSet/subscription-notification-type could not be resolved`
- `StructureDefinition/twiin-subscription-status: StructureDefinition.snapshot.element[42].binding.valueSet: A definition could not be found for Canonical URL ...`

Related warnings on each example: `ValueSet 'http://hl7.org/fhir/ValueSet/subscription-notification-type' not found`.

## Binding on `channel.payload` cannot be expanded

Applies to: IG Publisher 3.0.0, `hl7.fhir.uv.subscriptions-backport.r4#1.1.0`. Not allowlisted (warning).

`Twiin Subscription.Subscription.channel.payload: Binding http://hl7.org/fhir/ValueSet/mimetypes|4.0.0 could not be expanded`. The binding comes from the base Subscription resource of the Backport package, which is based on FHIR 4.0.0 (see above); the publisher cannot expand `mimetypes|4.0.0`. This IG binds `channel.payload` to its own value set `twiin-notification-formats`.

## No OIDs before 1.0.0

Warning `The resource ValueSet/twiin-notification-formats should have an OID assigned ...` is suppressed in `input/ignoreWarnings.txt`. No OIDs are assigned before version 1.0.0. The same suggestion for the other resources is reported as information and is not suppressed.

## Not fixed by `twiin.base.template#0.1.2`

Applies to: `twiin.base.template#0.1.2` (based on `fhir2.base.template#0.1.0`) with IG Publisher 3.0.0. The template fixes the redirect to `en/` for non-English browsers, the empty release label, the doubled `<h2 id="root">` on profile history pages and the not well formed profile pages (see its [README](https://github.com/TwiinNL/ig-template)); this repository has no workarounds for those any more. What remains, the same with `fhir2.base.template#0.1.0` alone and also listed in the template README:

- `searchform.html` has its own markup that the publisher reports as not well formed: 8 warnings for `output/searchform.html` and 8 for `output/en/searchform.html` (16 in total, not allowlisted, warnings do not fail the build).
- Profile history pages are not in the page list of the publisher, so their breadcrumb bar is empty and the heading has no section number.
