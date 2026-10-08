Profile: TwiinSubscription
Parent: http://hl7.org/fhir/uv/subscriptions-backport/StructureDefinition/backport-subscription
Id: twiin-subscription
Title: "Twiin Subscription"
Description: "Subscription under TA Notifications (TA section Resource Definitions → Subscription). Restricts channel.type to rest-hook and channel.payload to application/fhir+json or application/fhir+xml. channel.endpoint is 1..1 because the TA requires the rest-hook channel type, which needs an endpoint; this cardinality is derived from that requirement, not stated separately in the TA."
* ^status = #draft
* ^experimental = false
* obeys twiin-sub-1
* channel.type = #rest-hook
* channel.endpoint 1..1
* channel.payload from TwiinNotificationFormats (required)

Invariant: twiin-sub-1
Description: "criteria is the canonical URL of a SubscriptionTopic: an http(s) URL without a query. This is a heuristic to catch an R4 search expression in criteria."
Expression: "criteria.matches('^https?://[^?]+$')"
Severity: #warning
