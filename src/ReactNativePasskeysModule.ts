import { Platform, requireNativeModule } from "expo-modules-core";
import type {
	PublicKeyCredentialCreationOptionsJSON,
	RegistrationResponseJSON,
	PublicKeyCredentialRequestOptionsJSON,
	AuthenticationResponseJSON,
} from "./ReactNativePasskeys.types";
import { NotSupportedError } from "./errors";

const passkeys = requireNativeModule("ReactNativePasskeys");

// It loads the native module object from the JSI or falls back to
// the bridge module (from NativeModulesProxy) if the remote debugger is on.
export default {
	...passkeys,

	async get(
		request: PublicKeyCredentialRequestOptionsJSON,
		requireBiometrics: boolean
	): Promise<AuthenticationResponseJSON | null> {
		return Platform.OS === "ios"
			? await passkeys.get(request, requireBiometrics)
			: await passkeys.get(request);
	},

	async create(
		request: PublicKeyCredentialCreationOptionsJSON,
		requireBiometrics: boolean
	): Promise<RegistrationResponseJSON | null> {
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
};
