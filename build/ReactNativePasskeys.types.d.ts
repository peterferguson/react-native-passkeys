import type { AuthenticationExtensionsClientInputs as TypeScriptAuthenticationExtensionsClientInputs, Base64URLString, AuthenticatorTransportFuture, PublicKeyCredentialJSON, PublicKeyCredentialDescriptorJSON, PublicKeyCredentialUserEntityJSON, AuthenticatorAttestationResponseJSON } from "@simplewebauthn/typescript-types";
export type { AttestationConveyancePreference, AuthenticationCredential, AuthenticatorAssertionResponse, AuthenticatorAttachment, AuthenticatorAttestationResponse, AuthenticatorSelectionCriteria, AuthenticatorTransport, COSEAlgorithmIdentifier, Crypto, PublicKeyCredentialCreationOptions, PublicKeyCredentialDescriptor, PublicKeyCredentialParameters, PublicKeyCredentialRequestOptions, PublicKeyCredentialRpEntity, PublicKeyCredentialType, PublicKeyCredentialUserEntity, RegistrationCredential, UserVerificationRequirement, } from "@simplewebauthn/typescript-types";
export type { Base64URLString, PublicKeyCredentialJSON, AuthenticatorTransportFuture, PublicKeyCredentialDescriptorJSON, PublicKeyCredentialUserEntityJSON, AuthenticatorAttestationResponseJSON, };
/**
 * A variant of PublicKeyCredentialCreationOptions suitable for JSON transmission
 *
 * This should eventually get replaced with official TypeScript DOM types when WebAuthn L3 types
 * eventually make it into the language:
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-publickeycredentialcreationoptionsjson
 */
export interface PublicKeyCredentialCreationOptionsJSON {
    rp: PublicKeyCredentialRpEntity;
    user: PublicKeyCredentialUserEntityJSON;
    challenge: Base64URLString;
    pubKeyCredParams: PublicKeyCredentialParameters[];
    timeout?: number;
    excludeCredentials?: PublicKeyCredentialDescriptorJSON[];
    authenticatorSelection?: AuthenticatorSelectionCriteria;
    attestation?: AttestationConveyancePreference;
    extensions?: AuthenticationExtensionsClientInputs;
}
/**
 * A variant of PublicKeyCredentialRequestOptions suitable for JSON transmission
 */
export interface PublicKeyCredentialRequestOptionsJSON {
    challenge: Base64URLString;
    timeout?: number;
    rpId?: string;
    allowCredentials?: PublicKeyCredentialDescriptorJSON[];
    userVerification?: UserVerificationRequirement;
    extensions?: AuthenticationExtensionsClientInputs;
}
/**
 * A slightly-modified RegistrationCredential to simplify working with ArrayBuffers that
 * are Base64URL-encoded so that they can be sent as JSON.
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-registrationresponsejson
 */
export interface RegistrationResponseJSON {
    id: Base64URLString;
    rawId: Base64URLString;
    response: AuthenticatorAttestationResponseJSON;
    authenticatorAttachment?: AuthenticatorAttachment;
    clientExtensionResults: AuthenticationExtensionsClientOutputsJSON;
    type: PublicKeyCredentialType;
}
/**
 * A slightly-modified AuthenticationCredential to simplify working with ArrayBuffers that
 * are Base64URL-encoded so that they can be sent as JSON.
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationresponsejson
 */
export interface AuthenticationResponseJSON {
    id: Base64URLString;
    rawId: Base64URLString;
    response: AuthenticatorAssertionResponseJSON;
    authenticatorAttachment?: AuthenticatorAttachment;
    clientExtensionResults: AuthenticationExtensionsClientOutputsJSON;
    type: PublicKeyCredentialType;
}
/**
 * A slightly-modified AuthenticatorAssertionResponse to simplify working with ArrayBuffers that
 * are Base64URL-encoded so that they can be sent as JSON.
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticatorassertionresponsejson
 */
export interface AuthenticatorAssertionResponseJSON {
    clientDataJSON: Base64URLString;
    authenticatorData: Base64URLString;
    signature: Base64URLString;
    userHandle?: string;
}
/**
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfinputs
 */
export interface AuthenticationExtensionsPRFInputs {
    /**
     * A single set of PRF inputs to evaluate for the selected credential.
     */
    eval?: {
        first: Base64URLString;
        second?: Base64URLString;
    };
    /**
     * A record mapping base64url-encoded credential IDs to PRF inputs.
     * Only valid during authentication when allowCredentials is specified.
     * Each credential can have different PRF inputs evaluated.
     */
    evalByCredential?: Record<Base64URLString, {
        first: Base64URLString;
        second?: Base64URLString;
    }>;
}
/**
 * TypeScript's types are behind the latest extensions spec, so we define them here.
 * Should eventually be replaced by TypeScript's when TypeScript gets updated to
 * know about it (sometime after 5.3)
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsclientinputs
 */
export interface AuthenticationExtensionsClientInputs extends TypeScriptAuthenticationExtensionsClientInputs {
    largeBlob?: AuthenticationExtensionsLargeBlobInputs;
    prf?: AuthenticationExtensionsPRFInputs;
}
export type LargeBlobSupport = "preferred" | "required";
/**
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargeblobinputs
 */
export interface AuthenticationExtensionsLargeBlobInputs {
    support?: LargeBlobSupport;
    read?: boolean;
    write?: Base64URLString;
}
export interface AuthenticationExtensionsClientOutputs {
    largeBlob?: Omit<AuthenticationExtensionsLargeBlobOutputs, "blob"> & {
        blob?: ArrayBuffer;
    };
    prf?: Omit<AuthenticationExtensionsPRFOutputsJSON, "results"> & {
        results: {
            first: ArrayBuffer;
            second?: ArrayBuffer;
        };
    };
    credProps?: CredentialPropertiesOutput;
}
export interface AuthenticationExtensionsClientOutputsJSON {
    largeBlob?: AuthenticationExtensionsLargeBlobOutputs;
    prf?: AuthenticationExtensionsPRFOutputsJSON;
    credProps?: CredentialPropertiesOutput;
}
/**
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargebloboutputs
 */
export interface AuthenticationExtensionsLargeBlobOutputs {
    supported?: boolean;
    blob?: Base64URLString;
    written?: boolean;
}
/**
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-credentialpropertiesoutput
 */
export interface CredentialPropertiesOutput {
    /**
     * This OPTIONAL property, known abstractly as the resident key credential property (i.e., client-side
     * discoverable credential property), is a Boolean value indicating whether the PublicKeyCredential
     * returned as a result of a registration ceremony is a client-side discoverable credential (passkey).
     *
     * If rk is true, the credential is a discoverable credential (resident key/passkey).
     * If rk is false, the credential is a server-side credential.
     * If rk is not present, it is not known whether the credential is a discoverable credential or not.
     */
    rk?: boolean;
}
/**
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfvalues
 */
export interface AuthenticationExtensionsPRFValuesJSON {
    first: Base64URLString;
    second?: Base64URLString;
}
/**
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfoutputs
 */
export interface AuthenticationExtensionsPRFOutputsJSON {
    enabled?: boolean;
    results?: AuthenticationExtensionsPRFValuesJSON;
}
/**
 * A library specific type that combines the JSON results of a registration operation with a method
 * to get the public key of the new credential since these are not available directly from the native side
 */
export interface CreationResponse extends Omit<RegistrationResponseJSON, "response"> {
    response: RegistrationResponseJSON["response"] & {
        /**
         * This operation returns a Base64URLString containing the DER SubjectPublicKeyInfo of the new credential, or null if this is not available.
         *
         * **Note:** This deviates from the standard Web Authentication API, which returns `ArrayBuffer | null` on web browsers.
         * For cross-platform consistency, this library converts the ArrayBuffer to Base64URLString on web platforms,
         * matching the native iOS/Android behavior where binary data is transmitted as Base64URL-encoded strings.
         *
         * @see https://w3c.github.io/webauthn/#dom-authenticatorattestationresponse-getpublickey
         */
        getPublicKey(): Base64URLString | null;
    };
}
//# sourceMappingURL=ReactNativePasskeys.types.d.ts.map