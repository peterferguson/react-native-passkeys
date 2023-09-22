import ExpoModulesCore

// - navigator.credentials.create request options
// - Specification reference: https://w3c.github.io/webauthn/#dictionary-makecredentialoptions
internal struct PublicKeyCredentialCreationResponse: Record {

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
