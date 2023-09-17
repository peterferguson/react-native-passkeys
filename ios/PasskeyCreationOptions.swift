import ExpoModulesCore

// - Enums

internal enum AttestationConveyancePreference: String {
    case direct
    case enterprise
    case indirect
    case none
}

// - Structs

struct PublicKeyCredentialRpEntity {
    let name: String
    let id: String?
}

struct PublicKeyCredentialEntity {
    let name: String
}

struct PublicKeyCredentialUserEntity {
    let name: String
    let displayName: String
    let id: BufferSource
}

struct PublicKeyCredentialParameters {
    let alg: COSEAlgorithmIdentifier
    let type: PublicKeyCredentialType
}

// - navigator.credentials.create request options
internal struct PublicKeyCredentialCreationOptions {

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
