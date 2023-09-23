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
} from './ExpoPasskeys.types'

// Import the native module. On web, it will be resolved to ExpoPasskeys.web.ts
// and on native platforms to ExpoPasskeys.ts
import ExpoPasskeysModule from './ExpoPasskeysModule'

export function isSupported(): boolean {
	return ExpoPasskeysModule.isSupported()
}

export async function create(
	request: Omit<PublicKeyCredentialCreationOptionsJSON, 'extensions'> & {
		// - only largeBlob is supported currently on iOS
		// - no extensions are currently supported on Android
		extensions?: { largeBlob?: AuthenticationExtensionsLargeBlobInputs }
	} & Pick<CredentialCreationOptions, 'signal'>,
): Promise<RegistrationResponseJSON | null> {
	return await ExpoPasskeysModule.create(request)
}

export async function get(
	request: Omit<PublicKeyCredentialRequestOptionsJSON, 'extensions'> & {
		// - only largeBlob is supported currently on iOS
		// - no extensions are currently supported on Android
		extensions?: { largeBlob?: AuthenticationExtensionsLargeBlobInputs }
	},
): Promise<AuthenticationResponseJSON | null> {
	return ExpoPasskeysModule.get(request)
}
