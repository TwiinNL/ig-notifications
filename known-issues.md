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
