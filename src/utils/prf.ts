import { base64URLStringToBuffer } from "./base64";
import type {
	PublicKeyCredentialCreationOptionsJSON,
	PublicKeyCredentialRequestOptionsJSON,
} from "../ReactNativePasskeys.types";

export function normalizePRFInputs(
	request: PublicKeyCredentialCreationOptionsJSON | PublicKeyCredentialRequestOptionsJSON,
) {
	const { prf } = request.extensions ?? {};

	if (!prf) {
		return;
	}

	const result: {
		eval?: { first: ArrayBuffer; second?: ArrayBuffer };
		evalByCredential?: Record<string, { first: ArrayBuffer; second?: ArrayBuffer }>;
	} = {};

	// Handle eval (single input)
	if (prf.eval) {
		result.eval = {
			first: base64URLStringToBuffer(prf.eval.first),
			second: prf.eval.second ? base64URLStringToBuffer(prf.eval.second) : undefined,
		};
	}

	// Handle evalByCredential (different inputs per credential)
	if (prf.evalByCredential) {
		// Validate that allowCredentials is specified per WebAuthn spec
		const allowCredentials = "allowCredentials" in request ? request.allowCredentials : undefined;
		if (!allowCredentials || allowCredentials.length === 0) {
			throw new Error("evalByCredential requires allowCredentials to be specified");
		}

		// Per WebAuthn spec: validate that all keys in evalByCredential match allowCredentials
		const allowedCredentialIds = new Set(allowCredentials.map((c) => c.id));

		result.evalByCredential = {};
		for (const [credentialId, prfValues] of Object.entries(prf.evalByCredential)) {
			// Validate: key must not be empty string and must equal id of some element of allowCredentials
			if (credentialId === "") {
				throw new Error("evalByCredential key cannot be empty string");
			}
			if (!allowedCredentialIds.has(credentialId)) {
				throw new Error(
					`evalByCredential key "${credentialId}" does not match any allowCredentials`,
				);
			}

			result.evalByCredential[credentialId] = {
				first: base64URLStringToBuffer(prfValues.first),
				second: prfValues.second ? base64URLStringToBuffer(prfValues.second) : undefined,
			};
		}
	}

	return Object.keys(result).length > 0 ? result : undefined;
}
