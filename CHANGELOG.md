# react-native-passkeys

## 0.4.2

### Patch Changes

- 052cbc5: - fix(android): call `isSupported()` before passkey creation so unsupported Android devices receive `NotSupportedError` (thanks @ncarthy, #66).

## 0.4.1

### Patch Changes

- 69c1f10: - fix(android): resolve JVM target mismatch on AGP 8+ with Kotlin 2.x by unifying Java and Kotlin toolchains via `kotlin.jvmToolchain(17)` (thanks @friederbluemle, #60).
  - chore: narrow supported Expo SDK range to `>=53.0.0` to match Expo's own support matrix.
  - chore: migrate lint/format tooling from Biome to oxlint + oxfmt.
  - docs(android): document the `get_login_creds` Digital Asset Links requirement for passkeys.

## 0.4.0

### Minor Changes

- Add PRF extension evalByCredential support and credProps extension across all platforms

## New Features

### PRF Extension - evalByCredential

- Add support for per-credential PRF inputs via `evalByCredential` property
- Allows different PRF salt inputs for each credential during authentication
- Implemented across iOS (iOS 18+), Android (API 34+), and Web platforms
- Includes validation that `allowCredentials` is specified when using `evalByCredential` per WebAuthn spec

### credProps Extension

- Add support for credential properties extension on Android and Web
- Returns whether a credential is client-side discoverable (resident key/passkey)
- iOS types included (commented) for future implementation

## Improvements

- Normalize `getPublicKey()` return type to Base64URLString across all platforms for consistency
- Improve type safety for credential responses
- Enhanced error handling and input validation on iOS
- Better documentation across Android and iOS implementations

## Example App

- Add demonstration of evalByCredential usage
- Upgrade Android compile SDK to 36
- Upgrade Expo SDK to 54
- Improve type safety and UI handling
- Add type definitions for @hexagon/base64

## Breaking Changes

- `getPublicKey()` now returns Base64URLString on web instead of ArrayBuffer for cross-platform consistency

## 0.3.2

### Patch Changes

- 7eca9ea: Fix iOS Safari crashing due to largeBlob empty object

  iOS Safari crashes when requesting a largeBlob credential with an empty object
  using the `get()` method.

  This patch passes undefined if the request does not include a largeBlob object.

## 0.3.1

### Minor Changes

- 739b73b: Adds `getPublicKey` method
  Fixes Android support for Expo SDK 51
  Fixes default attestation preference to `none` on iOS

## 0.1.6

### Patch Changes

- update client extension types

## 0.1.5

### Patch Changes

- fix AuthenticatorSelectionCriteria input

## 0.1.4

### Patch Changes

- remove only-allow preinstall

## 0.1.3

### Patch Changes

- update types to extend simplewebauthn

## 0.1.2

### Patch Changes

- 8aab9e3: Initial iOS and web implementation
