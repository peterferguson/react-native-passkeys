import { requireNativeModule } from "expo-modules-core";
import { NotSupportedError } from "./errors";

import type {
	PublicKeyCredentialCreationOptionsJSON,
	RegistrationResponseJSON,
	PublicKeyCredentialRequestOptionsJSON,
	AuthenticationResponseJSON,
} from "./ReactNativePasskeys.types";

// It loads the native module object from the JSI or falls back to
// the bridge module (from NativeModulesProxy) if the remote debugger is on.
const passkeys = requireNativeModule("ReactNativePasskeys");

export default {
	...passkeys,

	async create(
		request: PublicKeyCredentialCreationOptionsJSON,
	): Promise<RegistrationResponseJSON | null> {
		if (!this.isSupported) throw new NotSupportedError();

		const credential = await passkeys.create(request);
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
