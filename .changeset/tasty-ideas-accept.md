---
"react-native-passkeys": patch
---

Fix iOS Safari crashing due to largeBlob empty object

iOS Safari crashes when requesting a largeBlob credential with an empty object
using the `get()` method.

This patch passes undefined if the request does not include a largeBlob object.
