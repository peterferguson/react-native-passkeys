import type {
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
} from './ExpoPasskeys.types'

// Import the native module. On web, it will be resolved to ExpoPasskeys.web.ts
// and on native platforms to ExpoPasskeys.ts
import ExpoPasskeysModule from './ExpoPasskeysModule'

export function isSupported(): boolean {
	return ExpoPasskeysModule.isSupported()
}

export async function get(
	request: PublicKeyCredentialRequestOptionsJSON,
): Promise<Credential | null> {
	return ExpoPasskeysModule.get(request)
}

export async function create(
	request: PublicKeyCredentialCreationOptionsJSON & Pick<CredentialCreationOptions, 'signal'>,
): Promise<Credential | null> {
	return await ExpoPasskeysModule.create(request)
}
