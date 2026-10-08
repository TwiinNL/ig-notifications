This page is informative. It lists the artifacts in this guide and the section of TA Notifications each one belongs to. The requirements themselves are in the TA.

### Profiles

| Artifact | Based on (Backport IG 1.1.0) | TA section |
|---|---|---|
| [Twiin Subscription](StructureDefinition-twiin-subscription.html) | `backport-subscription` | Resource Definitions → Subscription; Creating a Subscription |
| [Twiin Subscription Status](StructureDefinition-twiin-subscription-status.html) | `backport-subscription-status-r4` | Resource Definitions → Notification (including Authorization value); $status and $events Operations |
| [Twiin Subscription Notification](StructureDefinition-twiin-subscription-notification.html) | `backport-subscription-notification-r4` | Resource Definitions → Notification |

Twiin Subscription Status does not restrict the values of `type`, because the same Parameters resource is returned by `$status` and `$events`. The restriction to handshake, heartbeat and event-notification is in Twiin Subscription Notification.

The `authorization-type` (Coding) and `authorization-value` (string) parts of `notification-event` are checked by invariant `twiin-st-5`, not by slices. They are allowed when type is event-notification or query-event. The part names are provisional: they are not defined in Backport IG 1.1.0 and follow the 1.2.0 ballot of the Backport IG.

Some invariants interpret the TA:

- `twiin-sub-1` checks that `criteria` is an http(s) URL without a query. It is a heuristic and has severity warning.
- `twiin-ntf-2` reads "the request MUST match a request to the $status operation" as exact string equality between `request.url` and the subscription reference followed by `/$status`.

### Terminology

| Artifact | TA section |
|---|---|
| [Twiin Notification Formats](ValueSet-twiin-notification-formats.html) | Resource Definitions → Subscription (channel.payload) |

### Capability statement

| Artifact | TA section |
|---|---|
| [Twiin Subscription Server](CapabilityStatement-twiin-subscription-server.html) | System Roles and Responsibilities → Subscription Server; Updating a Subscription; $status and $events Operations; Preconditions (mTLS) |

The capability statement imports the Backport IG Subscription Server capability statement for R4 (`backport-subscription-server-r4`, version 1.1.0). Some of its expectations differ from the imported ones (update SHALL instead of SHOULD, delete SHOULD-NOT instead of SHOULD, search parameters). The IG Publisher renders only this guide's own expectations and a note that the Backport statement is imported; it does not merge them. Where they differ, the expectations in this capability statement reflect the TA.

### Examples

| Example | TA section |
|---|---|
| [Subscription: create, id-only](Subscription-subscription-create-id-only.html) | Creating a Subscription → Example |
| [Subscription: retire](Subscription-7f3e9a2c-5d18-4b6f-9c3a-8e2d4f6b1a59.html) | Updating a Subscription → Example |
| [Notification: handshake](Bundle-notification-handshake.html) | Handshake Notification → Example |
| [Notification: heartbeat](Bundle-notification-heartbeat.html) | Heartbeat Notification → Example |
| [Notification: event-notification, id-only](Bundle-notification-event-id-only.html) | Event Notification → Example |
| [Notification: event-notification, empty](Bundle-notification-event-empty.html) | Resource Definitions → Notification (not a TA example) |
| [Notification: event-notification, full-resource](Bundle-notification-event-full-resource.html) | Resource Definitions → Notification (not a TA example) |
| [$status response](Bundle-status-response.html) | $status and $events Operations (not a TA example) |
| [$events response with authorization value](Bundle-events-response-auth.html) | $status and $events Operations; Resource Definitions → Notification → Authorization value (not a TA example) |

The Subscription examples add `reason`, which FHIR R4 requires and the TA examples omit. All examples use the hosts `sender.example.org` and `receiver.example.org` instead of `sender.example` and `receiver.example` in the TA: the IG Publisher reports an error for each absolute reference to a `.example` host that it cannot resolve, and not for `example.org`.
