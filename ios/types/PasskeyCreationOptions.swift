import ExpoModulesCore
import AuthenticationServices

// - Structs

// - Specification reference: https://w3c.github.io/webauthn/#dictionary-pkcredentialentity
struct PublicKeyCredentialEntity: Record {
    // ! Not optional but we have to make it comply with `Record`
    @Field
    var name: String?
}


// - Specification reference: https://w3c.github.io/webauthn/#dictionary-credential-params
struct PublicKeyCredentialParameters: Record {
    // ! the defaults here are NOT the standard but they are most widely supported & popular
    @Field
    var alg: COSEAlgorithmIdentifier = -7
    
    @Field
    var type: PublicKeyCredentialType = .publicKey
    
    func appleise() -> ASAuthorizationPublicKeyCredentialParameters {
        return ASAuthorizationPublicKeyCredentialParameters.init(algorithm: ASCOSEAlgorithmIdentifier(rawValue: self.alg))
    }
}

// - navigator.credentials.create request options
// - Specification reference: https://w3c.github.io/webauthn/#dictionary-makecredentialoptions
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

}
