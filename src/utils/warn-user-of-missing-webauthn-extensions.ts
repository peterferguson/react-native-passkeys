import type {
	AuthenticationExtensionsClientInputs,
	AuthenticationExtensionsClientOutputs,
} from "../ReactNativePasskeys.types";

/**
 *  warn the user about extensions that they tried to use that are not supported
 */
export const warnUserOfMissingWebauthnExtensions = (
	requestedExtensions: AuthenticationExtensionsClientInputs | undefined,
	clientExtensionResults: AuthenticationExtensionsClientOutputs | undefined,
) => {
	if (clientExtensionResults) {
		for (const key in requestedExtensions) {
			if (typeof clientExtensionResults[key] === "undefined") {
				alert(
					`Webauthn extension ${key} is undefined -- your browser probably doesn't know about it`,
				);
			}
		}
	}
};
