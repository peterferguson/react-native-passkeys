import type { PublicKeyCredentialCreationOptionsJSON, PublicKeyCredentialRequestOptionsJSON } from "../ReactNativePasskeys.types";
export declare function normalizePRFInputs(request: PublicKeyCredentialCreationOptionsJSON | PublicKeyCredentialRequestOptionsJSON): {
    eval?: {
        first: ArrayBuffer;
        second?: ArrayBuffer;
    };
    evalByCredential?: Record<string, {
        first: ArrayBuffer;
        second?: ArrayBuffer;
    }>;
} | undefined;
//# sourceMappingURL=prf.d.ts.map