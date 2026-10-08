Profile: TwiinSubscriptionNotification
Parent: http://hl7.org/fhir/uv/subscriptions-backport/StructureDefinition/backport-subscription-notification-r4
Id: twiin-subscription-notification
Title: "Twiin Subscription Notification"
Description: "Notification Bundle under TA Notifications (TA section Resource Definitions → Notification), sent by the Subscription Server for handshake, heartbeat and event-notification."
* ^status = #draft
* ^experimental = false
* obeys twiin-ntf-1 and twiin-ntf-2 and twiin-ntf-3 and twiin-ntf-4
* entry[subscriptionStatus].resource only TwiinSubscriptionStatus

Invariant: twiin-ntf-1
Description: "The type in the subscription status is handshake, heartbeat or event-notification."
Expression: "entry.first().resource.parameter.where(name = 'type').value.all($this = 'handshake' or $this = 'heartbeat' or $this = 'event-notification')"
Severity: #error

Invariant: twiin-ntf-2
Description: "The request of the first entry is GET on the subscription reference followed by /$status. The TA requires the request to match a request to the $status operation; this invariant interprets that as exact string equality with the subscription reference."
Expression: "entry.first().request.method = 'GET' and entry.first().request.url = entry.first().resource.parameter.where(name = 'subscription').value.reference.first() + '/$status'"
Severity: #error

Invariant: twiin-ntf-3
Description: "Without a notification-event.focus, there is no notification-event.additional-context and no entry other than the first."
Expression: "entry.first().resource.parameter.where(name = 'notification-event').part.where(name = 'focus').empty() implies (entry.first().resource.parameter.where(name = 'notification-event').part.where(name = 'additional-context').empty() and entry.count() = 1)"
Severity: #error

Invariant: twiin-ntf-4
Description: "Every entry after the first carries fullUrl and request."
Expression: "entry.skip(1).all(fullUrl.exists() and request.exists())"
Severity: #error
