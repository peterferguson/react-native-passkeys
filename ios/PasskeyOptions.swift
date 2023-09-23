import ExpoModulesCore
import AuthenticationServices

/**
 navigator.credentials.create request options
 
 Specification reference: https://w3c.github.io/webauthn/#dictionary-makecredentialoptions
*/
internal struct PublicKeyCredentialCreationOptions: Record {

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
    // var extensions: JavaScriptObject?

}

/**
 navigator.credentials.get request options
 
 Specification reference: https://w3c.github.io/webauthn/#dictionary-assertion-options
 */
internal struct PublicKeyCredentialRequestOptions: Record {
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
