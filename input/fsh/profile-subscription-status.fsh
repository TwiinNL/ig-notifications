Profile: TwiinSubscriptionStatus
Parent: http://hl7.org/fhir/uv/subscriptions-backport/StructureDefinition/backport-subscription-status-r4
Id: twiin-subscription-status
Title: "Twiin Subscription Status"
Description: "Subscription status Parameters under TA Notifications (TA section Resource Definitions → Notification). Used as the first entry of a notification Bundle and in $status and $events responses, so the values of type are not restricted here; see twiin-subscription-notification for the restriction that applies to notifications."
* ^status = #draft
* ^experimental = false
* obeys twiin-st-1 and twiin-st-2 and twiin-st-3 and twiin-st-4 and twiin-st-5
* parameter[topic] 1..1
* parameter[notificationEvent].part contains
    authType 0..1 and
    authValue 0..1
* parameter[notificationEvent].part[authType] ^short = "Authorization mechanism of the authorization value (provisional)"
* parameter[notificationEvent].part[authType] ^definition = "Identifies the authorization mechanism that authorization-value belongs to. Provisional: not defined in Backport IG 1.1.0; slice name and part name follow the 1.2.0 ballot of the Backport IG (notification-authorization-hint) and may change with a published version."
* parameter[notificationEvent].part[authType].name = "authorization-type"
* parameter[notificationEvent].part[authType].value[x] 1..1
* parameter[notificationEvent].part[authType].value[x] only Coding
* parameter[notificationEvent].part[authValue] ^short = "Authorization value for the subsequent pull (provisional)"
* parameter[notificationEvent].part[authValue] ^definition = "Authorization value the Subscription Client needs for the subsequent pull. Provisional: not defined in Backport IG 1.1.0; slice name and part name follow the 1.2.0 ballot of the Backport IG (notification-authorization-hint) and may change with a published version."
* parameter[notificationEvent].part[authValue].name = "authorization-value"
* parameter[notificationEvent].part[authValue].value[x] 1..1
* parameter[notificationEvent].part[authValue].value[x] only string

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
Description: "authorization-type and authorization-value occur together, and only if type is event-notification."
Expression: "parameter.where(name = 'notification-event').all(part.where(name = 'authorization-type').exists() = part.where(name = 'authorization-value').exists()) and (parameter.where(name = 'notification-event').part.where(name = 'authorization-type' or name = 'authorization-value').exists() implies parameter.where(name = 'type' and value = 'event-notification').exists())"
Severity: #error
