import type {
	AuthenticationCredential,
	AuthenticationExtensionsLargeBlobInputs,
	AuthenticationExtensionsLargeBlobOutputs,
	AuthenticationExtensionsPRFInputs,
	AuthenticationResponseJSON,
	Base64URLString,
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
	RegistrationCredential,
	RegistrationResponseJSON,
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
		// - only largeBlob is supported currently on iOS
		// - no extensions are currently supported on Android
		extensions?: {
			largeBlob?: AuthenticationExtensionsLargeBlobInputs;
			prf?: AuthenticationExtensionsPRFInputs;
		};
	} & Pick<CredentialCreationOptions, "signal">,
): Promise<CreationResponse | null> {
	return await ReactNativePasskeysModule.create(request);
}

export async function get(
	request: Omit<PublicKeyCredentialRequestOptionsJSON, "extensions"> & {
		// - only largeBlob is supported currently on iOS
		// - no extensions are currently supported on Android
		extensions?: {
			largeBlob?: AuthenticationExtensionsLargeBlobInputs;
			prf?: AuthenticationExtensionsPRFInputs;
		};
	},
): Promise<AuthenticationResponseJSON | null> {
	return await ReactNativePasskeysModule.get(request);
}
