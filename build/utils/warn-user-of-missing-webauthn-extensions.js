/**
 *  warn the user about extensions that they tried to use that are not supported
 */
export const warnUserOfMissingWebauthnExtensions = (requestedExtensions, clientExtensionResults) => {
    if (clientExtensionResults) {
        for (const key in requestedExtensions) {
            if (typeof clientExtensionResults[key] === "undefined") {
                alert(`Webauthn extension ${key} is undefined -- your browser probably doesn't know about it`);
            }
        }
    }
};
//# sourceMappingURL=warn-user-of-missing-webauthn-extensions.js.map