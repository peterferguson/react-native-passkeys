// - Polyfill TextEncoder
import "fast-text-encoding";

import { Platform } from "react-native";
import { atob, btoa } from 'react-native-quick-base64'

// - Polyfill Buffer
if (typeof Buffer === "undefined") {
  global.Buffer = require("buffer").Buffer;
}

// - Polyfill atob and btoa
if (Platform.OS !== 'web') {
	global.atob = atob
	global.btoa = btoa
}

export { Slot as default } from 'expo-router'
