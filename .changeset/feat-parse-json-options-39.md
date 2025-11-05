---
"react-native-passkeys": minor
---

Add support for parseCreationOptionsFromJSON and parseRequestOptionsFromJSON across all platforms

This change exports `parseCreationOptionsFromJSON` and `parseRequestOptionsFromJSON` functions, enabling cross-platform JSON-to-WebAuthn conversion following the WebAuthn Level 3 specification.

**New Exports:**
- `parseCreationOptionsFromJSON(json)` - Converts PublicKeyCredentialCreationOptionsJSON to native format
- `parseRequestOptionsFromJSON(json)` - Converts PublicKeyCredentialRequestOptionsJSON to native format

**Implementation:**
- Added comprehensive JSON conversion utilities matching Chromium's implementation (`src/utils/json.ts`)
- Web platform uses browser's native `PublicKeyCredential.parseCreationOptionsFromJSON` and `parseRequestOptionsFromJSON`
- Native platforms (iOS/Android) already accept JSON format, these utilities provide validation and type safety
- Handles all credential fields including challenge, user, excludeCredentials, allowCredentials
- Supports all WebAuthn extensions (PRF, largeBlob, credProps)
- Proper base64url encoding/decoding for ArrayBuffer fields

**Additional utilities:**
- Added `isJSONFormat` utility to detect JSON vs binary format
- Extracted extension warning logic to separate module

**Benefits:**
- ✨ Cross-platform API consistency
- 📋 WebAuthn Level 3 spec compliance
- 🔧 Type-safe JSON conversion with helpful error messages
- 🎯 ~100 fewer lines in web module through code consolidation
- 🚀 Native browser methods on web for optimal performance

Fixes #39
