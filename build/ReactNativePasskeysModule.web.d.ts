import type { AuthenticationResponseJSON, CreationResponse, PublicKeyCredentialCreationOptionsJSON, PublicKeyCredentialRequestOptionsJSON } from "./ReactNativePasskeys.types";
declare const _default: {
    readonly name: string;
    isAutoFillAvalilable(): Promise<boolean>;
    isSupported(): boolean;
    create({ signal, ...request }: PublicKeyCredentialCreationOptionsJSON & Pick<CredentialCreationOptions, "signal">): Promise<CreationResponse | null>;
    get({ mediation, signal, ...request }: PublicKeyCredentialRequestOptionsJSON & Pick<CredentialRequestOptions, "mediation" | "signal">): Promise<AuthenticationResponseJSON | null>;
};
export default _default;
//# sourceMappingURL=ReactNativePasskeysModule.web.d.ts.map