# Atlas security and backend preparation

Atlas is local-first today. This document defines the boundary for future cloud and Open Finance work without introducing production credentials or destructive migrations.

## Rules

- Never commit API keys, OAuth client secrets, private keys, banking credentials, refresh tokens, or production access tokens.
- The Flutter client may hold short-lived user session material only when a platform secure-storage implementation is introduced.
- Open Finance OAuth authorization, client authentication, token exchange/refresh and provider secrets belong on a trusted backend.
- Financial calculations that can be deterministic remain deterministic; an AI layer may explain results but must not become the source of truth for balances.
- Existing local persisted data remains readable. Cloud synchronization must be additive and versioned.
- Logs and analytics must not contain raw banking payloads, credentials, full account identifiers, or sensitive transaction descriptions by default.

## Prepared interfaces

`AtlasBackend` is the future authentication/backend boundary. `OpenFinanceGateway` is the future account-data boundary. The checked-in implementation is intentionally disabled/local and returns no real banking data.

## Future implementation sequence

1. Add environment-aware configuration containing public/non-secret identifiers only.
2. Add platform secure storage for short-lived session material.
3. Deploy a trusted backend with authentication, authorization, encryption in transit, secret management and audit logging.
4. Integrate an approved Open Finance provider through that backend using sandbox credentials first.
5. Add explicit consent, revocation, data-retention and account-disconnection flows before any production banking connection.
6. Add sync conflict/version handling so existing local data is preserved.

Production Open Finance remains deliberately out of scope for this preparation stage.
