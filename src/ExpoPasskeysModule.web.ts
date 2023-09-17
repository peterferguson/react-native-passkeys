import type {
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
} from "./ExpoPasskeys.types";
import { NotSupportedError } from "./errors";
import { base64URLStringToBuffer } from "./utils/base64";

export default {
	get name(): string {
		return "ExpoPasskeys";
	},
	isAutoFillAvalilable(): Promise<boolean> {
		const globalPublicKeyCredential = window.PublicKeyCredential;

		if (globalPublicKeyCredential.isConditionalMediationAvailable === undefined)
			return new Promise((resolve) => resolve(false));

		return globalPublicKeyCredential.isConditionalMediationAvailable();
	},

	isSupported() {
		return (
			window?.PublicKeyCredential !== undefined && typeof window.PublicKeyCredential === "function"
		);
	},

	async get({
		mediation,
		signal,
		...request
	}: PublicKeyCredentialRequestOptionsJSON &
		Pick<CredentialRequestOptions, "mediation" | "signal">): Promise<Credential | null> {
		return navigator.credentials.get({
			mediation,
			signal,
			publicKey: {
				...request,
				challenge: base64URLStringToBuffer(request.challenge),
				allowCredentials: request.allowCredentials?.map((credential) => ({
					...credential,
					id: base64URLStringToBuffer(credential.id),
				})),
			},
		});
	},

	async create({
		signal,
		...request
	}: PublicKeyCredentialCreationOptionsJSON &
		Pick<CredentialCreationOptions, "signal">): Promise<Credential | null> {
		if (!this.isSupported) throw new NotSupportedError();

		return navigator.credentials.create({
			signal,
			publicKey: {
				...request,
				challenge: base64URLStringToBuffer(request.challenge),
				user: { ...request.user, id: base64URLStringToBuffer(request.user.id) },
				excludeCredentials: request.excludeCredentials?.map((credential) => ({
					...credential,
					id: base64URLStringToBuffer(credential.id),
				})),
			},
		});
	},
};
