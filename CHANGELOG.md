# react-native-passkeys

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
