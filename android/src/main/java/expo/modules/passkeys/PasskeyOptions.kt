import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record


/**
navigator.credentials.get request options

Specification reference: https://w3c.github.io/webauthn/#dictionary-assertion-options
 */
class PublicKeyCredentialCreationOptions: Record {

    @Field
    var rp: PublicKeyCredentialRpEntity = PublicKeyCredentialRpEntity()

    @Field
    var user: PublicKeyCredentialUserEntity = PublicKeyCredentialUserEntity()

    @Field
    var challenge: String = ""

    @Field
    var pubKeyCredParams: List<PublicKeyCredentialParameters> = listOf()

    @Field
    var timeout: Int? = null

    @Field
    var excludeCredentials: List<PublicKeyCredentialDescriptor>? = null

    @Field
    var authenticatorSelection: AuthenticatorSelectionCriteria? = null

    @Field
    var attestation: String? = null

    @Field
    var extensions: AuthenticationExtensionsClientInputs? = null

}

class AuthenticatorSelectionCriteria: Record {

    @Field
    var authenticatorAttachment: String? = null

    @Field
    var residentKey: String? = null

    @Field
    var requireResidentKey: Boolean? = null

    @Field
    var userVerification: String? = null
}

class PublicKeyCredentialParameters: Record {
    @Field
    var type: String = ""

    @Field
    var alg: Long = 0
}

/**
navigator.credentials.get request options

Specification reference: https://w3c.github.io/webauthn/#dictionary-assertion-options
 */
class PublicKeyCredentialRequestOptions: Record {
    @Field
    var challenge: String = ""

    @Field
    var rpId: String = ""

    // TODO: implement the timeout
    @Field
    var timeout: Int? = null

    @Field
    var allowCredentials: List<PublicKeyCredentialDescriptor>? = null

    @Field
    var userVerification: String? = null

    @Field
    var extensions: AuthenticationExtensionsClientInputs? = null
}

class PublicKeyCredentialRpEntity: Record {

    @Field
    var name: String = ""

    @Field
    var id: String? = null
}

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-publickeycredentialuserentity
 */
class PublicKeyCredentialUserEntity: Record {

    @Field
    var name: String = ""

    @Field
    var displayName: String = ""

    @Field
    var id: String = ""
}


/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-publickeycredentialdescriptor
 */
class PublicKeyCredentialDescriptor: Record {

    @Field
    var id: String = ""

    @Field
    var transports: List<String>? = null

    @Field
    var type: String = "public-key"
}

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsclientinputs
 */
class AuthenticationExtensionsClientInputs: Record {

    // Not supported on Android yet
    // @Field
    // var largeBlob: AuthenticationExtensionsLargeBlobInputs? = null

    @Field
    var prf: AuthenticationExtensionsPRFInputs? = null
}

// /**
// Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargeblobinputs
//  */
// class AuthenticationExtensionsLargeBlobInputs: Record {

//     @Field
//     var support: String? = null

//     @Field
//     var read: Boolean? = null

//     @Field
//     var write: String? = null
// }

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfinputs
 */
class AuthenticationExtensionsPRFInputs: Record {

    @Field
    var eval: AuthenticationExtensionsPRFValues? = null

    @Field
    var evalByCredential: Map<String, AuthenticationExtensionsPRFValues>? = null
}

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfvalues
 */
class AuthenticationExtensionsPRFValues: Record {

    @Field
    var first: String = ""

    @Field
    var second: String? = null
}

class RegistrationResponseJSON: Record {
    @Field
    var id: String = ""

    @Field
    var rawId: String = ""

    @Field
    var response: AuthenticatorAttestationResponseJSON = AuthenticatorAttestationResponseJSON()

    @Field
    var authenticatorAttachment: String? = null

    @Field
    var clientExtensionResults: AuthenticationExtensionsClientOutputsJSON? = null

    @Field
    var type: String = "public-key"
}

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticatorattestationresponsejson
 */
class AuthenticatorAttestationResponseJSON: Record {

    @Field
    var clientDataJSON: String = ""

    // - Required in L3 but not in L2 so leaving optional as most have not adapted L3 yet
    @Field
    var authenticatorData: String? = null

    // - Required in L3 but not in L2 so leaving optional as most have not adapted L3 yet
    @Field
    var transports: List<String>? = null

    @Field
    var publicKeyAlgorithm: Int? = null

    @Field
    var publicKey: String? = null

    @Field
    var attestationObject: String = ""
}

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationresponsejson
 */
class AuthenticationResponseJSON: Record {

    @Field
    var type: String = "public-key"

    // - base64URL version of rawId
    @Field
    var id: String = ""

    @Field
    var rawId: String? = null

    @Field
    var authenticatorAttachment: String? = null

    @Field
    var response: AuthenticatorAssertionResponseJSON = AuthenticatorAssertionResponseJSON()

    @Field
    var clientExtensionResults: AuthenticationExtensionsClientOutputsJSON? = null
}


class AuthenticatorAssertionResponseJSON: Record {

    @Field
    var authenticatorData: String = ""

    @Field
    var clientDataJSON: String = ""

    @Field
    var signature: String = ""

    @Field
    var userHandle: String? = null

    @Field
    var attestationObject: String? = null

}

class AuthenticationExtensionsClientOutputsJSON: Record {

    // Not supported on Android yet
    // @Field
    // var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON? = null

    @Field
    var prf: AuthenticationExtensionsPRFOutputsJSON? = null

    @Field
    var credProps: CredentialPropertiesOutput? = null

}

// /**
// Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargebloboutputs
//  */
// class AuthenticationExtensionsLargeBlobOutputsJSON: Record {

//     @Field
//     var supported: Boolean? = null;

//     @Field
//     var blob: String? = null;

//     @Field
//     var written: Boolean? = null;
// };

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-credentialpropertiesoutput
 */
class CredentialPropertiesOutput: Record {

    /**
     * This OPTIONAL property, known abstractly as the resident key credential property (i.e., client-side
     * discoverable credential property), is a Boolean value indicating whether the PublicKeyCredential
     * returned as a result of a registration ceremony is a client-side discoverable credential (passkey).
     * 
     * If rk is true, the credential is a discoverable credential (resident key/passkey).
     * If rk is false, the credential is a server-side credential.
     * If rk is not present, it is not known whether the credential is a discoverable credential or not.
     */
    @Field
    var rk: Boolean? = null
}

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfoutputs
 */
class AuthenticationExtensionsPRFOutputsJSON: Record {

    @Field
    var enabled: Boolean? = null;

    @Field
    var results: AuthenticationExtensionsPRFValuesJSON? = null;
}

/**
Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsprfvaluesjson
 */
class AuthenticationExtensionsPRFValuesJSON: Record {

    @Field
    var first: String = "";

    @Field
    var second: String? = null;
}