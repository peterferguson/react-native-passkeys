---
"react-native-passkeys": patch
---

- fix(android): call `isSupported()` before passkey creation so unsupported Android devices receive `NotSupportedError` (thanks @ncarthy, #66).
