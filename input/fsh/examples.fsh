Alias: $filter = http://hl7.org/fhir/uv/subscriptions-backport/StructureDefinition/backport-filter-criteria
Alias: $content = http://hl7.org/fhir/uv/subscriptions-backport/StructureDefinition/backport-payload-content

RuleSet: TaSubscription
* criteria = "https://example.org/fhir/SubscriptionTopic/task-status-change"
* criteria.extension[filterCriteria].url = $filter
* criteria.extension[filterCriteria].valueString = "owner=http://fhir.nl/fhir/NamingSystem/ura|12104037"
// Subscription.reason is 1..1 in FHIR R4; the TA examples omit it.
* reason = "Notification of Task status changes"
* channel.type = #rest-hook
* channel.endpoint = "https://receiver.example/fhir/notifications"
* channel.payload = #application/fhir+json
* channel.payload.extension[content].url = $content
* channel.payload.extension[content].valueCode = #id-only

RuleSet: TaStatus(status, type)
* parameter[subscription].name = "subscription"
* parameter[subscription].valueReference.reference = "https://sender.example/fhir/Subscription/7f3e9a2c-5d18-4b6f-9c3a-8e2d4f6b1a59"
* parameter[topic].name = "topic"
* parameter[topic].valueCanonical = "https://example.org/fhir/SubscriptionTopic/task-status-change"
* parameter[status].name = "status"
* parameter[status].valueCode = #{status}
* parameter[type].name = "type"
* parameter[type].valueCode = #{type}

RuleSet: TaStatusEntry(fullUrl, status)
* entry[0].fullUrl = "{fullUrl}"
* entry[0].resource = {status}
* entry[0].request.method = #GET
* entry[0].request.url = "https://sender.example/fhir/Subscription/7f3e9a2c-5d18-4b6f-9c3a-8e2d4f6b1a59/$status"
* entry[0].response.status = "200"

Instance: subscription-create-id-only
InstanceOf: TwiinSubscription
Usage: #example
Title: "Subscription: create, id-only"
Description: "Subscription request with the topic canonical, a scoping filter and the id-only payload mode (TA section Creating a Subscription → Example). An id is added because every IG instance needs one; reason is added because FHIR R4 requires it."
* status = #requested
* insert TaSubscription

Instance: 7f3e9a2c-5d18-4b6f-9c3a-8e2d4f6b1a59
InstanceOf: TwiinSubscription
Usage: #example
Title: "Subscription: retire (status off)"
Description: "Retiring the Subscription from the create example (TA section Updating a Subscription → Example). reason is added because FHIR R4 requires it."
* status = #off
* insert TaSubscription

Instance: notification-handshake
InstanceOf: TwiinSubscriptionNotification
Usage: #example
Title: "Notification: handshake"
Description: "Handshake Bundle, sent while Subscription.status is still requested (TA section Handshake Notification → Example)."
* type = #history
* insert TaStatusEntry(urn:uuid:9e41b2d7-3c85-4f1a-b6e0-2d7c8a5f4e13, notification-handshake-status)

Instance: notification-handshake-status
InstanceOf: TwiinSubscriptionStatus
Usage: #inline
* insert TaStatus(requested, handshake)

Instance: notification-heartbeat
InstanceOf: TwiinSubscriptionNotification
Usage: #example
Title: "Notification: heartbeat"
Description: "Heartbeat Bundle for an active Subscription (TA section Heartbeat Notification → Example)."
* type = #history
* insert TaStatusEntry(urn:uuid:0364d735-381d-4a15-89fd-597e557b0ce2, notification-heartbeat-status)

Instance: notification-heartbeat-status
InstanceOf: TwiinSubscriptionStatus
Usage: #inline
* insert TaStatus(active, heartbeat)
* parameter[eventsSinceSubscriptionStart].name = "events-since-subscription-start"
* parameter[eventsSinceSubscriptionStart].valueString = "42"

Instance: notification-event-id-only
InstanceOf: TwiinSubscriptionNotification
Usage: #example
Title: "Notification: event-notification, id-only"
Description: "Id-only event-notification for a topic that monitors Task (TA section Event Notification → Example). The second entry identifies the resource that triggered the event and carries no resource content."
* type = #history
* insert TaStatusEntry(urn:uuid:c3a5d8f1-9b2e-4d67-8a4c-5e1f7b9d2a36, notification-event-id-only-status)
* entry[1].fullUrl = "https://sender.example/fhir/Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"
* entry[1].request.method = #PUT
* entry[1].request.url = "Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"
* entry[1].response.status = "200"

Instance: notification-event-id-only-status
InstanceOf: TwiinSubscriptionStatus
Usage: #inline
* insert TaStatus(active, event-notification)
* parameter[notificationEvent].name = "notification-event"
* parameter[notificationEvent].part[eventNumber].name = "event-number"
* parameter[notificationEvent].part[eventNumber].valueString = "42"
* parameter[notificationEvent].part[eventTimestamp].name = "timestamp"
* parameter[notificationEvent].part[eventTimestamp].valueInstant = "2026-07-16T09:15:00Z"
* parameter[notificationEvent].part[eventFocus].name = "focus"
* parameter[notificationEvent].part[eventFocus].valueReference.reference = "https://sender.example/fhir/Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"

Instance: notification-event-empty
InstanceOf: TwiinSubscriptionNotification
Usage: #example
Title: "Notification: event-notification, empty"
Description: "Empty event-notification: no focus, no additional-context and no entry other than the subscription status (TA section Resource Definitions → Notification). Not an example from the TA."
* type = #history
* insert TaStatusEntry(urn:uuid:4b8e2f6a-1d3c-4a59-8e7b-2c6f9a0d5e14, notification-event-empty-status)

Instance: notification-event-empty-status
InstanceOf: TwiinSubscriptionStatus
Usage: #inline
* insert TaStatus(active, event-notification)
* parameter[notificationEvent].name = "notification-event"
* parameter[notificationEvent].part[eventNumber].name = "event-number"
* parameter[notificationEvent].part[eventNumber].valueString = "43"
* parameter[notificationEvent].part[eventTimestamp].name = "timestamp"
* parameter[notificationEvent].part[eventTimestamp].valueInstant = "2026-07-16T10:02:00Z"

Instance: notification-event-full-resource
InstanceOf: TwiinSubscriptionNotification
Usage: #example
Title: "Notification: event-notification, full-resource"
Description: "Full-resource event-notification: focus plus the resource content in the second entry (TA section Resource Definitions → Notification). Not an example from the TA."
* type = #history
* insert TaStatusEntry(urn:uuid:7a1c3e5f-9b2d-4f60-8a4e-6d0b2c8f1e37, notification-event-full-resource-status)
* entry[1].fullUrl = "https://sender.example/fhir/Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"
* entry[1].resource = 5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d
* entry[1].request.method = #PUT
* entry[1].request.url = "Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"
* entry[1].response.status = "200"

Instance: notification-event-full-resource-status
InstanceOf: TwiinSubscriptionStatus
Usage: #inline
* insert TaStatus(active, event-notification)
* parameter[notificationEvent].name = "notification-event"
* parameter[notificationEvent].part[eventNumber].name = "event-number"
* parameter[notificationEvent].part[eventNumber].valueString = "44"
* parameter[notificationEvent].part[eventTimestamp].name = "timestamp"
* parameter[notificationEvent].part[eventTimestamp].valueInstant = "2026-07-16T11:30:00Z"
* parameter[notificationEvent].part[eventFocus].name = "focus"
* parameter[notificationEvent].part[eventFocus].valueReference.reference = "https://sender.example/fhir/Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"

Instance: 5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d
InstanceOf: Task
Usage: #inline
* status = #ready
* intent = #order

Instance: status-response
InstanceOf: Bundle
Usage: #example
Title: "$status response"
Description: "Response to GET [base]/Subscription/[id]/$status: a searchset Bundle with the subscription status (TA section $status and $events Operations). Not an example from the TA."
* type = #searchset
* total = 1
* entry[0].fullUrl = "urn:uuid:2d9f4b1e-6a3c-4e78-9b5d-1f8c0a7e3d62"
* entry[0].resource = status-response-status
* entry[0].search.mode = #match

Instance: status-response-status
InstanceOf: TwiinSubscriptionStatus
Usage: #inline
* insert TaStatus(active, query-status)
* parameter[eventsSinceSubscriptionStart].name = "events-since-subscription-start"
* parameter[eventsSinceSubscriptionStart].valueString = "44"

Instance: events-response-auth
InstanceOf: Bundle
Usage: #example
Title: "$events response with authorization value"
Description: "Response to GET [base]/Subscription/[id]/$events replaying one id-only event-notification of an out-of-band Subscription, with the provisional authorization-type and authorization-value parts (TA sections $status and $events Operations; Resource Definitions → Notification → Authorization value). Not an example from the TA. The authorization-type code is a placeholder: the codes are defined by GF Authorization."
* type = #history
* entry[0].fullUrl = "urn:uuid:5e3a9c1d-7b4f-4e28-a6d0-9f2b8c4e1a73"
* entry[0].resource = events-response-auth-status
* entry[0].request.method = #GET
* entry[0].request.url = "https://sender.example/fhir/Subscription/7f3e9a2c-5d18-4b6f-9c3a-8e2d4f6b1a59/$events?eventsSinceNumber=42&eventsUntilNumber=42"
* entry[0].response.status = "200"
* entry[1].fullUrl = "https://sender.example/fhir/Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"
* entry[1].request.method = #PUT
* entry[1].request.url = "Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"
* entry[1].response.status = "200"

Instance: events-response-auth-status
InstanceOf: TwiinSubscriptionStatus
Usage: #inline
* insert TaStatus(active, query-event)
* parameter[notificationEvent].name = "notification-event"
* parameter[notificationEvent].part[eventNumber].name = "event-number"
* parameter[notificationEvent].part[eventNumber].valueString = "42"
* parameter[notificationEvent].part[eventTimestamp].name = "timestamp"
* parameter[notificationEvent].part[eventTimestamp].valueInstant = "2026-07-16T09:15:00Z"
* parameter[notificationEvent].part[eventFocus].name = "focus"
* parameter[notificationEvent].part[eventFocus].valueReference.reference = "https://sender.example/fhir/Task/5f2f9a4e-8c1d-4b6e-9d3a-7c0e2f4b8a1d"
* parameter[notificationEvent].part[3].name = "authorization-type"
* parameter[notificationEvent].part[3].valueCoding = https://example.org/CodeSystem/authorization-type#example
* parameter[notificationEvent].part[4].name = "authorization-value"
* parameter[notificationEvent].part[4].valueString = "Zk3p9QxT2mVb7LcW8nRy"
