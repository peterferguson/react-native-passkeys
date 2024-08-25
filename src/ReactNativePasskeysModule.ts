import { requireNativeModule } from "expo-modules-core";
import type {
	PublicKeyCredentialCreationOptionsJSON,
	RegistrationResponseJSON,
} from "./ReactNativePasskeys.types";
import { NotSupportedError } from "./errors";

const passkeys = requireNativeModule("ReactNativePasskeys");

// It loads the native module object from the JSI or falls back to
// the bridge module (from NativeModulesProxy) if the remote debugger is on.
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
