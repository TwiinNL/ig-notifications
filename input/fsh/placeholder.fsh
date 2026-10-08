// TEMPORARY: R4 requires ImplementationGuide.definition.resource to have at least one entry,
// so an IG without artifacts cannot build without errors. Remove this file before the first release.
Instance: twiin-placeholder
InstanceOf: Questionnaire
Usage: #definition
Title: "Twiin Placeholder"
Description: "Scaffold placeholder; remove before first release."
* name = "TwiinPlaceholder"
* title = "Twiin Placeholder"
* description = "Scaffold placeholder; remove before first release."
* status = #draft
* experimental = true
* item[+].linkId = "deliberate-error"
* item[=].type = #boolean
* item[=].initial.valueString = "not a boolean"
* item[=].answerValueSet = "http://example.org/does-not-exist"
