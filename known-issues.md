# Known issues

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

## eld-5 on the authorization part slices

Applies to: SUSHI 3.20.1, IG Publisher 3.0.0. Allowlisted in [known-errors.txt](known-errors.txt).

`Parameters.parameter.part` has a `contentReference`. SUSHI writes `type: BackboneElement` on a new slice of it (`authType`, `authValue`), and the publisher keeps the `contentReference` in the snapshot of that slice, so the snapshot element has both and fails eld-5 (`StructureDefinition.snapshot.element[93]`). The slices that the Backport IG itself defines on `part` have a type and no `contentReference` in its snapshot. No FSH rule was found that avoids this; not verified upstream. Instance validation is not affected: the invalid test instances for `twiin-st-5` are reported as expected (see README, Invariant tests).

## Absolute references to sender.example cannot be resolved

Applies to: IG Publisher 3.0.0. Allowlisted in [known-errors.txt](known-errors.txt), one line per example.

TA Notifications requires the subscription reference in a notification to be an absolute URL. The examples use `https://sender.example/fhir/Subscription/...` from the TA. The publisher tries to resolve absolute references and reports an error (`Reference_REF_CantResolve`) for each example that carries one. Re-check when examples are added or renamed: each line names the example.
