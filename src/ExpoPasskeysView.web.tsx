import * as React from 'react';

import { ExpoPasskeysViewProps } from './ExpoPasskeys.types';

export default function ExpoPasskeysView(props: ExpoPasskeysViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
