import type {
	AuthenticationCredential,
	AuthenticationExtensionsLargeBlobInputs,
	AuthenticationExtensionsLargeBlobOutputs,
	AuthenticationResponseJSON,
	Base64URLString,
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
	RegistrationCredential,
	RegistrationResponseJSON,
} from './ReactNativePasskeys.types'

// Import the native module. On web, it will be resolved to ReactNativePasskeys.web.ts
// and on native platforms to ReactNativePasskeys.ts
import ReactNativePasskeysModule from './ReactNativePasskeysModule'

export function isSupported(): boolean {
	return ReactNativePasskeysModule.isSupported()
}

export function isAutoFillAvalilable(): boolean {
	return ReactNativePasskeysModule.isAutoFillAvalilable()
}

export async function create(
	request: Omit<PublicKeyCredentialCreationOptionsJSON, 'extensions'> & {
		// - only largeBlob is supported currently on iOS
		// - no extensions are currently supported on Android
		extensions?: { largeBlob?: AuthenticationExtensionsLargeBlobInputs }
	} & Pick<CredentialCreationOptions, 'signal'>,
): Promise<RegistrationResponseJSON | null> {
	return await ReactNativePasskeysModule.create(request)
}

export async function get(
	request: Omit<PublicKeyCredentialRequestOptionsJSON, 'extensions'> & {
		// - only largeBlob is supported currently on iOS
		// - no extensions are currently supported on Android
		extensions?: { largeBlob?: AuthenticationExtensionsLargeBlobInputs }
	},
): Promise<AuthenticationResponseJSON | null> {
	return ReactNativePasskeysModule.get(request)
}
