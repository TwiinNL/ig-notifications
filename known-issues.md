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

## Template `fhir2.base.template#0.1.0`

Applies to: `fhir2.base.template#0.1.0` (the only version on packages2.fhir.org, 2026-10-09) with IG Publisher 3.0.0. Both bugs are fixed on the `main` branch of [HL7/ig-template-base2](https://github.com/HL7/ig-template-base2) (`lang-redirects.js`: commits 3c6dc8c9 and 28239381; `layout-profile-history.html`: commit 5b8c9667) but are not in a published version. `package.json` there still says 0.1.0.

Remove both workarounds below when a template version containing these fixes is published and `ig.ini` points to it. The check in `test/lang-redirects.test.js` reports a notice when the template's own file changes.

### Redirect stops after the first language

The template builds every page into `output/en/` and leaves a stub page in the root of `output/` that loads `assets/js/lang-redirects.js`. In 0.1.0 the `return;` in the loop of `doRedirect()` sits outside the `if`:

```js
for (i=0;i<langs.length;i++) {
  if ((userLang == langs[i]) || userLang.startsWith(langs[i]+"-")) {
    window.location.replace(langs[i]+"/"+pageName);
  }
  return;
}
window.location.replace(langs[0]+"/"+pageName);   // never reached
```

A browser whose language is not `en` (for example `nl`, `nl-NL`, `de`) is not redirected and stays on the empty stub page. Workaround: `input/images/assets/js/lang-redirects.js` is the file from HL7/ig-template-base2 `main`, copied verbatim (sha-256 `8a4dec2d77c9dff3a2b67f3574f0aef17f69e68812833550519c9cb2857e527d`). Source commits: [3c6dc8c9](https://github.com/HL7/ig-template-base2/commit/3c6dc8c9) ("Fix redirect for non-EN browsers", the `return` fix) and [28239381](https://github.com/HL7/ig-template-base2/commit/28239381151925bb4794b69c1c5738fdcb4b3ef6) ("Update lang-redirects.js", keeps `search` and `hash` in the redirect), checked on `main` at 2c669969 (2026-10-09). The override can go as soon as a template release after 0.1.0 contains these commits and `ig.ini` uses it: delete `input/images/assets/js/lang-redirects.js` and the "Test language redirect" step if the template's own file passes `test/lang-redirects.test.js`.

The publisher copies `input/images/` over the template's `content/`, so both `output/assets/js/lang-redirects.js` and `output/en/assets/js/lang-redirects.js` are this file. `test/lang-redirects.test.js` checks that, and runs the redirect for `nl`, `nl-NL`, `de`, `en` and `en-US`, and with a query string and a fragment (CI step "Test language redirect"). This is observed behaviour of the publisher, not documented; the test fails if it stops working. The override is a source file of the IG, so every build from this repository applies it, including the publication build (`-go-publish`). That build has not been run for this change; run `node test/lang-redirects.test.js` on its output before publishing.

The sha-256 of the faulty template file is `7ea6ae46a27c877dc47cc7ac0df4cc05f01b8debcbeec66db372da7577e92383`.

### Two `<h2 id="root">` on the profile history pages

Applies to: `StructureDefinition-<id>.profile.history.html`, one error per profile. The template's `layouts/layout-profile-history.html` has two `<h2 id="root">` lines in a row, and the second is not closed. The publisher's WCAG check reports it as an error. Allowlisted in [known-errors.txt](known-errors.txt) (3 lines, one per profile; the location is the path in `output/`):

- `output/en/StructureDefinition-twiin-subscription.profile.history.html`
- `output/en/StructureDefinition-twiin-subscription-notification.profile.history.html`
- `output/en/StructureDefinition-twiin-subscription-status.profile.history.html`

each with `The page has more than one top level heading: <h2> (no text) is at the same level as the first heading on the page (<h2> '…' (id=root)). A page must have exactly one top level heading, with every other heading beneath it (WCAG compliance test)`.

The same layouts produce 29 warnings that are not allowlisted (`html source is not well formed` on the profile, history and `searchform.html` pages; `duplicate element ids: root` on the history pages). Remove the three lines from `known-errors.txt` when the template is fixed. A new profile adds a line.
