import ExpoModulesCore

/// Specification reference: https://w3c.github.io/webauthn/#typedefdef-publickeycredentialjson
typealias PublicKeyCredentialJSON = Either<RegistrationResponseJSON, AuthenticationResponseJSON>

/// Specification reference: https://w3c.github.io/webauthn/#dictdef-registrationresponsejson
internal struct RegistrationResponseJSON: Record {
    @Field
    var id: Base64URLString

    @Field
    var rawId: Base64URLString

    @Field
    var response: AuthenticatorAttestationResponseJSON

    @Field
    var authenticatorAttachment: AuthenticatorAttachment?

    @Field
    var clientExtensionResults: AuthenticationExtensionsClientOutputsJSON?

    @Field
    var type: PublicKeyCredentialType = .publicKey
}

/// Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticatorattestationresponsejson
internal struct AuthenticatorAttestationResponseJSON: Record {

    @Field
    var clientDataJSON: Base64URLString

    // - Required in L3 but not in L2 so leaving optional as most have not adapted L3 yet
    @Field
    var authenticatorData: Base64URLString?

    // - Required in L3 but not in L2 so leaving optional as most have not adapted L3 yet
    @Field
    var transports: [AuthenticatorTransport]?

    @Field
    var publicKeyAlgorithm: Int?

    @Field
    var publicKey: Base64URLString?

    @Field
    var attestationObject: Base64URLString
}

/// Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationresponsejson
internal struct AuthenticationResponseJSON: Record {

    @Field
    var type: PublicKeyCredentialType = .publicKey

    // - base64URL version of rawId
    @Field
    var id: Base64URLString

    @Field
    var rawId: Base64URLString?

    @Field
    var authenticatorAttachment: AuthenticatorAttachment?

    @Field
    var response: AuthenticatorAssertionResponseJSON

    @Field
    var clientExtensionResults: AuthenticationExtensionsClientOutputsJSON?
}

/// Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticatorassertionresponsejson
internal struct AuthenticatorAssertionResponseJSON: Record {

    @Field
    var authenticatorData: Base64URLString

    @Field
    var clientDataJSON: Base64URLString

    @Field
    var signature: Base64URLString

    @Field
    var userHandle: Base64URLString?

    @Field
    var attestationObject: Base64URLString?

}

/// Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsclientoutputsjson
internal struct AuthenticationExtensionsClientOutputsJSON: Record {

    // ? this is only available in iOS 17 but I cannot set this here
    // @available(iOS 17.0, *)
    @Field
    var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON?

    @Field
    var prf: AuthenticationExtensionsPRFOutputsJSON?

    // - credProps extension is not supported on iOS yet
    // https://w3c.github.io/webauthn/#sctn-authenticator-credential-properties-extension
    // @Field
    // var credProps: CredentialPropertiesOutput?
}

/// We convert this to `AuthenticationExtensionsLargeBlobOutputsJSON` instead of `AuthenticationExtensionsLargeBlobOutputs` for consistency
/// and because it is what is actually returned to RN
///
/// Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargebloboutputsjson
internal struct AuthenticationExtensionsLargeBlobOutputsJSON: Record {

    @Field
    var supported: Bool?

    @Field
    var blob: Base64URLString?

    @Field
    var written: Bool?
}

// /// Specification reference: https://w3c.github.io/webauthn/#dictdef-credentialpropertiesoutput
// internal struct CredentialPropertiesOutput: Record {
//     /**
//      * This OPTIONAL property, known abstractly as the resident key credential property (i.e., client-side
//      * discoverable credential property), is a Boolean value indicating whether the PublicKeyCredential
//      * returned as a result of a registration ceremony is a client-side discoverable credential (passkey).
//      *
//      * If rk is true, the credential is a discoverable credential (resident key/passkey).
//      * If rk is false, the credential is a server-side credential.
//      * If rk is not present, it is not known whether the credential is a discoverable credential or not.
//      */
//     @Field
//     var rk: Bool?
// }

internal struct AuthenticationExtensionsPRFValuesJSON: Record {
    @Field
    var first: Base64URLString

    @Field
    var second: Base64URLString?
}

/// Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfoutputsjson
internal struct AuthenticationExtensionsPRFOutputsJSON: Record {
    @Field
    var enabled: Bool?

    @Field
    var results: AuthenticationExtensionsPRFValuesJSON?
}
