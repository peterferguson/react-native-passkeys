import type {
	AuthenticationExtensionsLargeBlobInputs,
	AuthenticationExtensionsPRFInputs,
	AuthenticationResponseJSON,
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
	CreationResponse,
} from "./ReactNativePasskeys.types";

// Import the native module. On web, it will be resolved to ReactNativePasskeys.web.ts
// and on native platforms to ReactNativePasskeys.ts
import ReactNativePasskeysModule from "./ReactNativePasskeysModule";

export function isSupported(): boolean {
	return ReactNativePasskeysModule.isSupported();
}

export function isAutoFillAvalilable(): boolean {
	return ReactNativePasskeysModule.isAutoFillAvalilable();
}

export async function create(
	request: Omit<PublicKeyCredentialCreationOptionsJSON, "extensions"> & {
		// Platform support:
		// - iOS: largeBlob (iOS 17+), prf (iOS 18+)
		// - Android: prf
		// - Web: largeBlob, prf
		extensions?: {
			largeBlob?: AuthenticationExtensionsLargeBlobInputs;
			prf?: AuthenticationExtensionsPRFInputs;
			// Request credProps on registration to learn discoverability.
			credProps?: boolean;
		};
	} & Pick<CredentialCreationOptions, "signal">,
): Promise<CreationResponse | null> {
	return await ReactNativePasskeysModule.create(request);
}

export async function get(
	request: Omit<PublicKeyCredentialRequestOptionsJSON, "extensions"> & {
		// Platform support:
		// - iOS: largeBlob (iOS 17+), prf (iOS 18+)
		// - Android: prf
		// - Web: largeBlob, prf
		extensions?: {
			largeBlob?: AuthenticationExtensionsLargeBlobInputs;
			prf?: AuthenticationExtensionsPRFInputs;
		};
	},
): Promise<AuthenticationResponseJSON | null> {
	return await ReactNativePasskeysModule.get(request);
}

// Export JSON conversion utilities for cross-platform use
export {
	publicKeyCredentialCreationOptionsFromJSON as parseCreationOptionsFromJSON,
	publicKeyCredentialRequestOptionsFromJSON as parseRequestOptionsFromJSON,
} from './utils/json';
