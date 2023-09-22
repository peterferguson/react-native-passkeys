import ExpoModulesCore

// - Specification reference: https://w3c.github.io/webauthn/#iface-authenticatorassertionresponse
internal struct AuthenticatorAssertionResponse: Record {
    
    // ! Not optional but we have to make it comply with `Record`
    @Field
    var authenticatorData: BufferSource?

    // ! Not optional but we have to make it comply with `Record`
    @Field
    var clientDataJSON: BufferSource?

    // ! Not optional but we have to make it comply with `Record`
    @Field
    var signature: BufferSource?
    
    @Field
    var userHandle: BufferSource?
    
}


// - Specification reference: https://w3c.github.io/webauthn/#iface-authenticatorattestationresponse
 struct AuthenticatorAttestationResponse: Record {
    // ! Not optional but we have to make it comply with `Record`
    @Field
    var attestationObject: BufferSource?
    
    // ! Not optional but we have to make it comply with `Record`
    @Field
    var clientDataJSON: BufferSource?
    
}

// - response for navigator.credential.create
// - Specification reference: https://w3c.github.io/webauthn/#iface-pkcredential
struct PublicKeyCredentialAttestationResponse: Record {
    
    @Field
    var type: PublicKeyCredentialType = .publicKey
    
    // - base64URL version of rawId
    @Field
    var id: Base64URLString

    // TODO: Maybe drop this since it will have to encoded to pass to RN
    @Field
    var rawId: BufferSource?

    @Field
    var authenticatorAttachment: AuthenticatorAttachment?
    
    @Field
    var response: AuthenticatorAttestationResponse
}

// - response for navigator.credential.create
// - Specification reference: https://w3c.github.io/webauthn/#iface-pkcredential
struct PublicKeyCredentialAssertionResponse: Record {
    
    @Field
    var type: PublicKeyCredentialType = .publicKey
    
    // - base64URL version of rawId
    @Field
    var id: Base64URLString

    // TODO: Maybe drop this since it will have to encoded to pass to RN
    @Field
    var rawId: BufferSource?

    @Field
    var authenticatorAttachment: AuthenticatorAttachment?
    
    @Field
    var response: AuthenticatorAssertionResponse
}
