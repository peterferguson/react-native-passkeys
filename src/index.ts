import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to ExpoPasskeys.web.ts
// and on native platforms to ExpoPasskeys.ts
import ExpoPasskeysModule from './ExpoPasskeysModule';
import ExpoPasskeysView from './ExpoPasskeysView';
import { ChangeEventPayload, ExpoPasskeysViewProps } from './ExpoPasskeys.types';

// Get the native constant value.
export const PI = ExpoPasskeysModule.PI;

export function hello(): string {
  return ExpoPasskeysModule.hello();
}

export async function setValueAsync(value: string) {
  return await ExpoPasskeysModule.setValueAsync(value);
}

const emitter = new EventEmitter(ExpoPasskeysModule ?? NativeModulesProxy.ExpoPasskeys);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { ExpoPasskeysView, ExpoPasskeysViewProps, ChangeEventPayload };
