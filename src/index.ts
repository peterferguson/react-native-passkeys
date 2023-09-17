// Import the native module. On web, it will be resolved to ExpoPasskeys.web.ts
// and on native platforms to ExpoPasskeys.ts
import ExpoPasskeysModule from './ExpoPasskeysModule';

export function hello(): string {
  return ExpoPasskeysModule.hello();
}
