import ExpoModulesCore

// - Enums

internal enum AttestationConveyancePreference: String {
    case direct
    case enterprise
    case indirect
    case none
}

// - Structs

struct PublicKeyCredentialEntity {
    let name: String
}


struct PublicKeyCredentialParameters: Record {
    // - defaulting to -7 this as it is the most widely supported
    @Field
    var alg: COSEAlgorithmIdentifier = -7 

    @Field
    var type: PublicKeyCredentialType = .publicKey
}

// - navigator.credentials.create request options
internal struct PublicKeyCredentialCreationOptions: Record {

    // TODO: figure out why I am forced to make these optional or get a 'No exact matches in call to initializer' error
    @Field
    var rp: PublicKeyCredentialRpEntity

    @Field
    var user: PublicKeyCredentialUserEntity

    @Field
    var challenge: Base64URLString

    @Field
    var pubKeyCredParams: [PublicKeyCredentialParameters]

    @Field
    var timeout: Int?

    @Field
    var excludeCredentials: [PublicKeyCredentialDescriptor]?

    @Field
    var authenticatorSelection: AuthenticatorSelectionCriteria?

    @Field
    var attestation: AttestationConveyancePreference?

    @Field
    var extensions: AuthenticationExtensionsClientInputs?

}
