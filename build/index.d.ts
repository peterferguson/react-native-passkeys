import type { AccountCreationResponse, AuthenticationExtensionsLargeBlobInputs, AuthenticationExtensionsPRFInputs, AuthenticationResponseJSON, FastAccountCreationOptions, PublicKeyCredentialCreationOptionsJSON, PublicKeyCredentialRequestOptionsJSON, CreationResponse } from "./ReactNativePasskeys.types";
export declare function isSupported(): boolean;
export declare function isAutoFillAvalilable(): boolean;
export declare function isAccountCreationSupported(): boolean;
export declare function create(request: Omit<PublicKeyCredentialCreationOptionsJSON, "extensions"> & {
    extensions?: {
        largeBlob?: AuthenticationExtensionsLargeBlobInputs;
        prf?: AuthenticationExtensionsPRFInputs;
        credProps?: boolean;
    };
} & Pick<CredentialCreationOptions, "signal">): Promise<CreationResponse | null>;
export declare function get(request: Omit<PublicKeyCredentialRequestOptionsJSON, "extensions"> & {
    extensions?: {
        largeBlob?: AuthenticationExtensionsLargeBlobInputs;
        prf?: AuthenticationExtensionsPRFInputs;
    };
}): Promise<AuthenticationResponseJSON | null>;
export declare function createAccount(request: FastAccountCreationOptions): Promise<AccountCreationResponse | null>;
//# sourceMappingURL=index.d.ts.map