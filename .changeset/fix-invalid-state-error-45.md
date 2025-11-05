---
"react-native-passkeys": patch
---

Fix iOS error handling to provide descriptive error messages for excludeCredentials

Previously, iOS would return generic error messages like "(null)" or "The operation couldn't be completed" when handling excludeCredentials errors. This fix enhances error handling on iOS to detect generic error messages and replace them with clear, descriptive messages that match the WebAuthn specification.

Changes:
- Added detection for generic/useless error messages from iOS
- Map ASAuthorizationError codes to proper WebAuthn error names
- Return descriptive error messages for all error cases including InvalidStateError for excludeCredentials

Fixes #45
