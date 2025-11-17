import { NotSupportedError } from "./errors";
import { base64URLStringToBuffer, bufferToBase64URLString } from "./utils/base64";

import type {
    AuthenticationCredential,
    AuthenticationExtensionsClientInputs,
    AuthenticationExtensionsClientOutputs,
    AuthenticationExtensionsClientOutputsJSON,
    AuthenticationResponseJSON,
    CreationResponse,
    PublicKeyCredentialCreationOptionsJSON,
    PublicKeyCredentialRequestOptionsJSON,
    RegistrationCredential,
} from "./ReactNativePasskeys.types";
import { normalizePRFInputs } from "./utils/prf";

export default {
	get name(): string {
		return "ReactNativePasskeys";
	},

	isAutoFillAvalilable(): Promise<boolean> {
		return window.PublicKeyCredential.isConditionalMediationAvailable?.() ?? Promise.resolve(false);
	},

	isSupported() {
		return (
			window?.PublicKeyCredential !== undefined && typeof window.PublicKeyCredential === "function"
		);
	},

	async create({
		signal,
		...request
	}: PublicKeyCredentialCreationOptionsJSON &
		Pick<CredentialCreationOptions, "signal">): Promise<CreationResponse | null> {
		if (!this.isSupported()) throw new NotSupportedError();

		const credential = (await navigator.credentials.create({
			signal,
			publicKey: {
				...request,
				challenge: base64URLStringToBuffer(request.challenge),
				user: { ...request.user, id: base64URLStringToBuffer(request.user.id) },
				excludeCredentials: request.excludeCredentials?.map((credential) => ({
					...credential,
					id: base64URLStringToBuffer(credential.id),
					// TODO: remove the override when typescript has updated webauthn types
					transports: (credential.transports ?? undefined) as AuthenticatorTransport[] | undefined,
				})),
				extensions: {
					...request.extensions,
					prf: normalizePRFInputs(request),
				},
			},
		})) as RegistrationCredential;

		// TODO: remove the override when typescript has updated webauthn types
		const extensions =
			credential?.getClientExtensionResults() as AuthenticationExtensionsClientOutputs;
		warnUserOfMissingWebauthnExtensions(request.extensions, extensions);
		const { largeBlob, prf, credProps, ...clientExtensionResults } = extensions;

		if (!credential) return null;

		return {
			id: credential.id,
			rawId: credential.id,
			response: {
				clientDataJSON: bufferToBase64URLString(credential.response.clientDataJSON),
				attestationObject: bufferToBase64URLString(credential.response.attestationObject),
				getPublicKey() {
					// Note: The standard web API returns ArrayBuffer | null, but we convert to Base64URLString
					// for cross-platform consistency with iOS/Android implementations
					const publicKey = credential.response.getPublicKey();
					return publicKey ? bufferToBase64URLString(publicKey) : null;
				},
			},
			authenticatorAttachment: undefined,
			type: "public-key",
			clientExtensionResults: {
				...clientExtensionResults,
				...(largeBlob && {
					largeBlob: {
						...largeBlob,
						blob: largeBlob?.blob ? bufferToBase64URLString(largeBlob.blob) : undefined,
					},
				}),
				...(prf?.results && {
					prf: {
						enabled: prf.enabled,
						results: {
							first: bufferToBase64URLString(prf.results.first),
							second: prf.results.second ? bufferToBase64URLString(prf.results.second) : undefined,
						},
					},
				}),
				...(credProps && { credProps }),
			} satisfies AuthenticationExtensionsClientOutputsJSON,
		};
	},

	async get({
		mediation,
		signal,
		...request
	}: PublicKeyCredentialRequestOptionsJSON &
		Pick<
			CredentialRequestOptions,
			"mediation" | "signal"
		>): Promise<AuthenticationResponseJSON | null> {
		const credential = (await navigator.credentials.get({
			mediation,
			signal,
			publicKey: {
				...request,
				extensions: {
					...request.extensions,
					prf: normalizePRFInputs(request),
					/**
					 * the navigator interface doesn't have a largeBlob property
					 * as it may not be supported by all browsers
					 *
					 * browsers that do not support the extension will just ignore the property so it's safe to include it
					 *
					 * @ts-expect-error:*/
					largeBlob: request.extensions?.largeBlob?.write
						? {
								...request.extensions?.largeBlob,
								write: base64URLStringToBuffer(request.extensions.largeBlob.write),
							}
						: request.extensions?.largeBlob,
				},
				challenge: base64URLStringToBuffer(request.challenge),
				allowCredentials: request.allowCredentials?.map((credential) => ({
					...credential,
					id: base64URLStringToBuffer(credential.id),
					// TODO: remove the override when typescript has updated webauthn types
					transports: (credential.transports ?? undefined) as AuthenticatorTransport[] | undefined,
				})),
			},
		})) as AuthenticationCredential;

		// TODO: remove the override when typescript has updated webauthn types
		const extensions =
			credential?.getClientExtensionResults() as AuthenticationExtensionsClientOutputs;
		warnUserOfMissingWebauthnExtensions(request.extensions, extensions);
		const { largeBlob, prf, credProps, ...clientExtensionResults } = extensions;

		if (!credential) return null;

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
			clientExtensionResults: {
				...clientExtensionResults,
				...(largeBlob && {
					largeBlob: {
						...largeBlob,
						blob: largeBlob?.blob ? bufferToBase64URLString(largeBlob.blob) : undefined,
					},
				}),
				...(prf?.results && {
					prf: {
						results: {
							first: bufferToBase64URLString(prf.results.first),
							second: prf.results.second ? bufferToBase64URLString(prf.results.second) : undefined,
						},
					},
				}),
				...(credProps && { credProps }),
			} satisfies AuthenticationExtensionsClientOutputsJSON,
			type: "public-key",
		};
	},
};

/**
 *  warn the user about extensions that they tried to use that are not supported
 */
const warnUserOfMissingWebauthnExtensions = (
	requestedExtensions: AuthenticationExtensionsClientInputs | undefined,
	clientExtensionResults: AuthenticationExtensionsClientOutputs | undefined,
) => {
	if (clientExtensionResults) {
		for (const key in requestedExtensions) {
			if (typeof (clientExtensionResults)[key] === "undefined") {
				alert(
					`Webauthn extension ${key} is undefined -- your browser probably doesn't know about it`,
				);
			}
		}
	}
};
