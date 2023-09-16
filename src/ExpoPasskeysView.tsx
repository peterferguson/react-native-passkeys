import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { ExpoPasskeysViewProps } from './ExpoPasskeys.types';

const NativeView: React.ComponentType<ExpoPasskeysViewProps> =
  requireNativeViewManager('ExpoPasskeys');

export default function ExpoPasskeysView(props: ExpoPasskeysViewProps) {
  return <NativeView {...props} />;
}
