import { Platform, requireNativeModule } from "expo-modules-core";
import { NotSupportedError } from "./errors";

import type {
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
	CreationResponse,
	AuthenticationResponseJSON,
} from "./ReactNativePasskeys.types";

// It loads the native module object from the JSI or falls back to
// the bridge module (from NativeModulesProxy) if the remote debugger is on.
const passkeys = requireNativeModule("ReactNativePasskeys");

export default {
	...passkeys,

	async create(
		request: PublicKeyCredentialCreationOptionsJSON,
		requireBiometrics: boolean,
	): Promise<CreationResponse | null> {
		if (!this.isSupported) throw new NotSupportedError();

		const credential =
			Platform.OS === "ios"
				? await passkeys.create(request, requireBiometrics)
				: await passkeys.create(request);

		return {
			...credential,
			response: {
				...credential.response,
				getPublicKey() {
					return credential.response?.publicKey;
				},
			},
		};
	},

	async get(
		request: PublicKeyCredentialRequestOptionsJSON,
		requireBiometrics: boolean,
	): Promise<AuthenticationResponseJSON | null> {
		return Platform.OS === "ios"
			? await passkeys.get(request, requireBiometrics)
			: await passkeys.get(request);
	},
};
