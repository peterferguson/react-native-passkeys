import type {
	AuthenticationCredential,
	AuthenticationResponseJSON,
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
	AuthenticationExtensionsClientInputs,
	RegistrationCredential,
	RegistrationResponseJSON,
} from './ReactNativePasskeys.types'
import { NotSupportedError } from './errors'
import { base64URLStringToBuffer, bufferToBase64URLString } from './utils/base64'

export default {
	get name(): string {
		return 'ReactNativePasskeys'
	},

	isAutoFillAvalilable(): Promise<boolean> {
		const globalPublicKeyCredential = window.PublicKeyCredential

		if (globalPublicKeyCredential.isConditionalMediationAvailable === undefined)
			return new Promise((resolve) => resolve(false))

		return globalPublicKeyCredential.isConditionalMediationAvailable()
	},

	isSupported() {
		return (
			window?.PublicKeyCredential !== undefined && typeof window.PublicKeyCredential === 'function'
		)
	},

	async create({
		signal,
		...request
	}: PublicKeyCredentialCreationOptionsJSON &
		Pick<CredentialCreationOptions, 'signal'>): Promise<RegistrationResponseJSON | null> {
		if (!this.isSupported) throw new NotSupportedError()

		const credential = (await navigator.credentials.create({
			signal,
			// @ts-expect-error: largeBlob is not included in the TS navigator credential types yet
			publicKey: {
				...request,
				challenge: base64URLStringToBuffer(request.challenge),
				user: { ...request.user, id: base64URLStringToBuffer(request.user.id) },
				excludeCredentials: request.excludeCredentials?.map((credential) => ({
					...credential,
					id: base64URLStringToBuffer(credential.id),
				})),
			},
		})) as RegistrationCredential

		const clientExtensionResults = credential?.getClientExtensionResults()

		warnUserOfMissingWebauthnExtensions(request.extensions, clientExtensionResults)

		if (!credential) return null

		return {
			id: credential?.id,
			rawId: credential.id,
			response: {
				clientDataJSON: bufferToBase64URLString(credential.response.clientDataJSON),
				attestationObject: bufferToBase64URLString(credential.response.attestationObject),
			},
			authenticatorAttachment: undefined,
			type: 'public-key',
			// @ts-expect-error: TS navigator credential clientExtensionResults types are behind
			clientExtensionResults,
		}
	},

	async get({
		mediation,
		signal,
		...request
	}: PublicKeyCredentialRequestOptionsJSON &
		Pick<
			CredentialRequestOptions,
			'mediation' | 'signal'
		>): Promise<AuthenticationResponseJSON | null> {
		const credential = (await navigator.credentials.get({
			mediation,
			signal,
			// @ts-expect-error: largeBlob is not included in the TS navigator credential types yet
			publicKey: {
				...request,
				challenge: base64URLStringToBuffer(request.challenge),
				allowCredentials: request.allowCredentials?.map((credential) => ({
					...credential,
					id: base64URLStringToBuffer(credential.id),
				})),
			},
		})) as AuthenticationCredential

		const clientExtensionResults = credential?.getClientExtensionResults()

		warnUserOfMissingWebauthnExtensions(request.extensions, clientExtensionResults)

		if (!credential) return null

		return {
			id: credential.id,
			rawId: credential.id,
			response: {
				clientDataJSON: bufferToBase64URLString(credential.response.clientDataJSON),
				authenticatorData: bufferToBase64URLString(credential.response.authenticatorData),
				signature: bufferToBase64URLString(credential.response.signature),
				userHandle: credential.response.userHandle
					? bufferToBase64URLString(credential.response.userHandle)
					: undefined,
			},
			authenticatorAttachment: undefined,
			// @ts-expect-error: TS navigator credential clientExtensionResults types are behind
			clientExtensionResults,
			type: 'public-key',
		}
	},
}

/**
 *  warn the user about extensions that they tried to use that are not supported
 */
const warnUserOfMissingWebauthnExtensions = (
	requestedExtensions: AuthenticationExtensionsClientInputs | undefined,
	clientExtensionResults: AuthenticationExtensionsClientOutputs | undefined,
) => {
	if (clientExtensionResults) {
		for (const key in requestedExtensions) {
			console.log(key, clientExtensionResults[key])
			if (typeof clientExtensionResults[key] === 'undefined') {
				alert(
					`Webauthn extension ${key} is undefined -- your browser probably doesn't know about it`,
				)
			}
		}
	}
}
