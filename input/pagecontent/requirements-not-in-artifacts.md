This page is informative. Many requirements of TA Notifications concern behaviour, agreements or infrastructure, and cannot be checked by validating a resource against the artifacts in this guide. This page points to the TA sections that contain them; it does not restate them.

| Topic | TA section |
|---|---|
| Choice of payload mode, and conditions on ids used in id-only mode | Notification Payload Model; Requirements for Using Id-Only; Appendix A |
| Agreement on and enforcement of the payload mode | Payload Mode Agreement and Enforcement |
| Authorization and processing basis, per Subscription and per notification | Privacy, Consent, and Authorization; Preconditions; Implementation Obligations |
| Authorization value for sender-initiated pulls: meaning, validity, use in-band | Authorization for Sender-Initiated Pulls; Resource Definitions → Notification |
| Verification of channel.endpoint and of the sending zorgaanbieder against GF Addressing | Preconditions; Subscription Client |
| Network security (mutual TLS) | Preconditions |
| Handshake and status transitions | Sequence Diagram; Handshake Notification; Implementation Obligations |
| Event-number assignment, gap detection and catch-up | Resource Definitions → Notification; Subscription Client; $status and $events Operations |
| Retry, exponential backoff and delivery failure | Implementation Obligations |
| Logging | Implementation Obligations |
| Error reporting with OperationOutcome | Implementation Obligations |
| Idempotent processing | Implementation Obligations |
| Permitted changes on update, and who may update | Updating a Subscription |
| Replacement of a Subscription | Replacing a Subscription |
| Heartbeat use and interval | Heartbeat Notification |
| Definition of SubscriptionTopics | Resource Definitions → SubscriptionTopic; Choosing a Resource Type to Monitor |
| Requirements on use-case-specific technical agreements | Requirements on Use-Case-Specific Technical Agreements |

Some requirements are partly expressed in artifacts. For example, the TA requires that the payload mode is not changed on an existing Subscription; no profile can check this, because it concerns two versions of a resource.
