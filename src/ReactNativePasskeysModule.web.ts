import { NotSupportedError } from "./errors";
import { bufferToBase64URLString } from "./utils/base64";

import type {
	AuthenticationCredential,
	AuthenticationExtensionsClientOutputs,
	AuthenticationResponseJSON,
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
	RegistrationCredential,
	CreationResponse,
} from "./ReactNativePasskeys.types";
import { authenticationExtensionsClientOutputsToJSON } from "./utils/json";
import { warnUserOfMissingWebauthnExtensions } from "./utils/warn-user-of-missing-webauthn-extensions";

export default {
	get name(): string {
		return "ReactNativePasskeys";
	},

	isAutoFillAvalilable(): Promise<boolean> {
		return PublicKeyCredential.isConditionalMediationAvailable?.() ?? Promise.resolve(false);
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
			publicKey: PublicKeyCredential.parseCreationOptionsFromJSON(request),
		})) as RegistrationCredential;

		// TODO: remove the override when typescript has updated webauthn types
		const extensions =
			credential?.getClientExtensionResults() as AuthenticationExtensionsClientOutputs;
		warnUserOfMissingWebauthnExtensions(request.extensions, extensions);

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
			clientExtensionResults: authenticationExtensionsClientOutputsToJSON(extensions),
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
			publicKey: PublicKeyCredential.parseRequestOptionsFromJSON(request),
		})) as AuthenticationCredential;

		// TODO: remove the override when typescript has updated webauthn types
		const extensions =
			credential?.getClientExtensionResults() as AuthenticationExtensionsClientOutputs;
		warnUserOfMissingWebauthnExtensions(request.extensions, extensions);

		if (!credential) return null;

		if (credential.toJSON) return credential.toJSON() as AuthenticationResponseJSON;

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
			clientExtensionResults: authenticationExtensionsClientOutputsToJSON(extensions),
			type: "public-key",
		};
	},
};