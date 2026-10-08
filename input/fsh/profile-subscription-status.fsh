Profile: TwiinSubscriptionStatus
Parent: http://hl7.org/fhir/uv/subscriptions-backport/StructureDefinition/backport-subscription-status-r4
Id: twiin-subscription-status
Title: "Twiin Subscription Status"
Description: "Subscription status Parameters under TA Notifications (TA section Resource Definitions → Notification). Used as the first entry of a notification Bundle and in $status and $events responses, so the values of type are not restricted here; see twiin-subscription-notification for the restriction that applies to notifications."
* ^status = #draft
* ^experimental = false
* obeys twiin-st-1 and twiin-st-2 and twiin-st-3 and twiin-st-4 and twiin-st-5
* parameter[topic] 1..1

Invariant: twiin-st-1
Description: "The subscription reference is an absolute http(s) URL."
Expression: "parameter.where(name = 'subscription').all(value.reference.exists() and value.reference.matches('^https?://[^ ]+$'))"
Severity: #error

Invariant: twiin-st-2
Description: "If type is event-notification, there is a notification-event, and every notification-event carries event-number and timestamp."
Expression: "parameter.where(name = 'type' and value = 'event-notification').exists() implies (parameter.where(name = 'notification-event').exists() and parameter.where(name = 'notification-event').all(part.where(name = 'event-number').exists() and part.where(name = 'timestamp').exists()))"
Severity: #error

Invariant: twiin-st-3
Description: "If type is heartbeat, events-since-subscription-start is present."
Expression: "parameter.where(name = 'type' and value = 'heartbeat').exists() implies parameter.where(name = 'events-since-subscription-start').exists()"
Severity: #error

Invariant: twiin-st-4
Description: "notification-event.focus is an absolute URL."
Expression: "parameter.where(name = 'notification-event').part.where(name = 'focus').all(value.reference.exists() and value.reference.matches('^https?://[^ ]+$'))"
Severity: #warning

Invariant: twiin-st-5
Description: "A notification-event has at most one authorization-type part, with a Coding value, and at most one authorization-value part, with a string value; the two occur together, and only if type is event-notification or query-event. The part names are provisional: they are not defined in Backport IG 1.1.0 and follow the 1.2.0 ballot of the Backport IG (notification-authorization-hint)."
Expression: "parameter.where(name = 'notification-event').all(part.where(name = 'authorization-type').count() <= 1 and part.where(name = 'authorization-value').count() <= 1 and (part.where(name = 'authorization-type').exists() = part.where(name = 'authorization-value').exists()) and part.where(name = 'authorization-type').all(value.ofType(Coding).exists()) and part.where(name = 'authorization-value').all(value.ofType(string).exists())) and (parameter.where(name = 'notification-event').part.where(name = 'authorization-type' or name = 'authorization-value').exists() implies parameter.where(name = 'type' and (value = 'event-notification' or value = 'query-event')).exists())"
Severity: #error
