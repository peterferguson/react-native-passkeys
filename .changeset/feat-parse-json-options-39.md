---
"react-native-passkeys": minor
---

Add support for parsing JSON credential options on web platform

This change implements support for the browser's native `parseCreationOptionsFromJSON` and `parseRequestOptionsFromJSON` static methods introduced in WebAuthn Level 3, enabling seamless conversion between JSON representations and WebAuthn credential options.

Changes:
- Added comprehensive JSON conversion utilities matching Chromium's implementation (`src/utils/json.ts`)
- Refactored web module to use `PublicKeyCredential.parseCreationOptionsFromJSON` and `PublicKeyCredential.parseRequestOptionsFromJSON`
- Simplified extension handling by leveraging native JSON parsing
- Added utility to detect JSON format vs binary format for future compatibility
- Extracted extension warning logic to separate module for better code organization

Benefits:
- Cleaner, more maintainable code with ~100 fewer lines in the web module
- Better compliance with WebAuthn Level 3 specification
- Proper handling of base64url encoding/decoding for all credential fields
- Improved extension support (PRF, largeBlob, credProps)

Fixes #39
