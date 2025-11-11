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

export interface PasskeysConfig {
	/**
	 * Options and configuration specific to the iOS platform.
	 */
	ios?: {
		/**
		 * Defines the [local authentication policy](https://developer.apple.com/documentation/localauthentication/lapolicy) to use:
		 * - `true`: Use the `deviceOwnerAuthenticationWithBiometrics` policy.
		 * - `false`: Use the `deviceOwnerAuthentication` policy.
		 * Defaults to `true`.
		 *
		 * @see {@linkcode https://developer.apple.com/documentation/localauthentication/lapolicy/deviceownerauthenticationwithbiometrics|LAPolicy.deviceOwnerAuthenticationWithBiometrics}
		 * @see {@linkcode https://developer.apple.com/documentation/localauthentication/lapolicy/deviceownerauthentication|LAPolicy.deviceOwnerAuthentication}
		 */
		requireBiometrics?: boolean;
	};
}

export interface PasskeysCreateOptions extends PasskeysConfig {}

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
	options?: PasskeysCreateOptions,
): Promise<CreationResponse | null> {
	return await ReactNativePasskeysModule.create(request, options?.ios?.requireBiometrics ?? true);
}

export interface PasskeysGetOptions extends PasskeysConfig {}

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
	options?: PasskeysGetOptions,
): Promise<AuthenticationResponseJSON | null> {
	return await ReactNativePasskeysModule.get(request, options?.ios?.requireBiometrics ?? true);
}
