import ExpoModulesCore

// - navigator.credentials.get request options
internal struct PublicKeyCredentialRequestOptions {
    @Field
    var challenge: Base64URLString 

    @Field
    var rpId: String?

    @Field
    var timeout: Int? = 60000

    @Field
    var allowCredentials: [PublicKeyCredentialDescriptor]?

    @Field
    var userVerification: UserVerificationRequirement?

    @Field
    var extensions: AuthenticationExtensionsClientInputs?
}
