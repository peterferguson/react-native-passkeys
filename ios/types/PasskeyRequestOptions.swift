import ExpoModulesCore

// - navigator.credentials.get request options
// - Specification reference: https://w3c.github.io/webauthn/#dictionary-assertion-options
internal struct PublicKeyCredentialRequestOptions: Record{
    @Field
    var challenge: Base64URLString

    @Field
    var rpId: String

    // TODO: implement the timeout
    @Field
    var timeout: Int? = 60000

    @Field
    var allowCredentials: [PublicKeyCredentialDescriptor]?

    @Field
    var userVerification: UserVerificationRequirement?

    @Field
    var extensions: AuthenticationExtensionsClientInputs?
}
