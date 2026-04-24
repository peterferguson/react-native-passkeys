import type { AccountCreationResponse, AuthenticationResponseJSON, FastAccountCreationOptions, PublicKeyCredentialCreationOptionsJSON, PublicKeyCredentialRequestOptionsJSON, CreationResponse } from "./ReactNativePasskeys.types";
declare const _default: {
    readonly name: string;
    isAutoFillAvalilable(): Promise<boolean>;
    isSupported(): boolean;
    isAccountCreationSupported(): boolean;
    create({ signal, ...request }: PublicKeyCredentialCreationOptionsJSON & Pick<CredentialCreationOptions, "signal">): Promise<CreationResponse | null>;
    get({ mediation, signal, ...request }: PublicKeyCredentialRequestOptionsJSON & Pick<CredentialRequestOptions, "mediation" | "signal">): Promise<AuthenticationResponseJSON | null>;
    createAccount(_request: FastAccountCreationOptions): Promise<AccountCreationResponse | null>;
};
export default _default;
//# sourceMappingURL=ReactNativePasskeysModule.web.d.ts.map