import ExpoModulesCore
import AuthenticationServices

// - Enums 

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-transport
*/
internal enum AuthenticatorTransport: String, Enumerable {
    case ble
    case hybrid
    case nfc
    case usb
    case internalTransport = "internal"
    case smartCard = "smart-card"


    func appleise() -> ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport? {
        switch self {
        case .ble: 
            return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.bluetooth
        case .nfc: 
            return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.nfc
        case .usb: 
            return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.usb
        // - including these to be clear that they are not yet supported on iOS although they exist in the spec
        // case .hybrid: 
        // case .internal: 
        // case .smart-card: 
        default: 
            // tODO: warn user
            return nil
        }
    }

}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-attachment
*/
internal enum AuthenticatorAttachment: String, Enumerable {
    case platform
    // - cross-platform marks that the user wants to select a security key
    case crossPlatform = "cross-platform"
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-attestation-convey
*/
internal enum AttestationConveyancePreference: String, Enumerable {
    case direct
    case enterprise
    case indirect
    case none

    func appleise() -> ASAuthorizationPublicKeyCredentialAttestationKind {
        switch self {
        case .direct:
            return ASAuthorizationPublicKeyCredentialAttestationKind.direct
        case .indirect:
            return ASAuthorizationPublicKeyCredentialAttestationKind.indirect
        case .enterprise:
            return ASAuthorizationPublicKeyCredentialAttestationKind.enterprise
        case .none:
            return ASAuthorizationPublicKeyCredentialAttestationKind.none
        default:
            return ASAuthorizationPublicKeyCredentialAttestationKind.none
        }
    }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-credentialType
*/
internal enum PublicKeyCredentialType: String, Enumerable {
    case publicKey = "public-key"
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-userVerificationRequirement
*/
internal enum UserVerificationRequirement: String, Enumerable {
    case discouraged
    case preferred
    case required

    func appleise () -> ASAuthorizationPublicKeyCredentialUserVerificationPreference {
        switch self {
        case .discouraged:
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.discouraged
        case .preferred:
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
        case .required:
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.required
        default:
            return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
        }
    }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enum-residentKeyRequirement
*/
internal enum ResidentKeyRequirement: String, Enumerable {
    case discouraged
    case preferred
    case required

    func appleise() -> ASAuthorizationPublicKeyCredentialResidentKeyPreference {
        switch self {
        case .discouraged:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.discouraged
        case .preferred:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
        case .required:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.required
        default:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
    }
    }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#enumdef-largeblobsupport
*/
internal enum LargeBlobSupport: String, Enumerable {
    case preferred
    case required
}

// - Structs

/**
    Specification reference: https://w3c.github.io/webauthn/#dictionary-authenticatorSelection
*/
internal struct AuthenticatorSelectionCriteria: Record {
    @Field
    var authenticatorAttachment: AuthenticatorAttachment?
    
    @Field
    var residentKey: ResidentKeyRequirement?;

    @Field
    var requireResidentKey: Bool? = false;
    
    @Field
    var userVerification: UserVerificationRequirement? = UserVerificationRequirement.preferred;
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictionary-pkcredentialentity
*/
internal struct PublicKeyCredentialEntity: Record {
    @Field
    var name: String
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictionary-credential-params
*/
internal struct PublicKeyCredentialParameters: Record {
    // ! the defaults here are NOT the standard but they are most widely supported & popular
    @Field
    var alg: COSEAlgorithmIdentifier = -7
    
    @Field
    var type: PublicKeyCredentialType = .publicKey
    
    func appleise() -> ASAuthorizationPublicKeyCredentialParameters {
        return ASAuthorizationPublicKeyCredentialParameters.init(algorithm: ASCOSEAlgorithmIdentifier(rawValue: self.alg))
    }
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictionary-rp-credential-params
*/
internal struct PublicKeyCredentialRpEntity: Record {
    
    @Field
    var name: String
    
    @Field
    var id: String?
}

/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-publickeycredentialuserentity
*/
internal struct PublicKeyCredentialUserEntity: Record {

    @Field
    var name: String

    @Field
    var displayName: String

    @Field
    var id: Base64URLString
}


/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-publickeycredentialdescriptor
*/
internal struct PublicKeyCredentialDescriptor: Record {

    @Field
    var id: Base64URLString

    @Field
    var transports: [AuthenticatorTransport]?

    @Field
    var type: PublicKeyCredentialType = .publicKey

    func getPlatformDescriptor() -> ASAuthorizationPlatformPublicKeyCredentialDescriptor {
        return ASAuthorizationPlatformPublicKeyCredentialDescriptor.init(credentialID: Data(base64URLEncoded: self.id)!)
    }
    
    func getCrossPlatformDescriptor() -> ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor {
        var transports = ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported
        
        if self.transports?.isEmpty == false {
            transports = self.transports!.compactMap { $0.appleise() }
        }
        
        return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.init(credentialID: Data(base64URLEncoded: self.id)!,
                                                                            transports: transports)
    }
}


/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargeblobinputs
*/
internal struct AuthenticationExtensionsLargeBlobInputs: Record {
    // - Only valid during registration.
    @Field
    var support: LargeBlobSupport?
    
    // - A boolean that indicates that the Relying Party would like to fetch the previously-written blob associated with the asserted credential. Only valid during authentication.
    @Field
    var read: Bool?
    
    // - An opaque byte string that the Relying Party wishes to store with the existing credential. Only valid during authentication.
    // - We impose that the data is passed as base64-url encoding to make better align the passing of data from RN to native code
    @Field
    var write: Base64URLString?
}


/**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsclientinputs
*/
internal struct AuthenticationExtensionsClientInputs: Record {
    
    @Field
    var largeBlob: AuthenticationExtensionsLargeBlobInputs?
}

// ! There is only one webauthn extension currently supported on iOS as of iOS 17.0:
// - largeBlob extension: https://w3c.github.io/webauthn/#sctn-large-blob-extension

internal struct AuthenticationExtensionsClientOutputs {
    
    /**
    Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargebloboutputs
*/
    internal struct AuthenticationExtensionsLargeBlobOutputs {
        // - true if, and only if, the created credential supports storing large blobs. Only present in registration outputs.
        let supported: Bool?;

        // - The opaque byte string that was associated with the credential identified by rawId. Only valid if read was true.
        let blob: Data?

        // - A boolean that indicates that the contents of write were successfully stored on the authenticator, associated with the specified credential.
        let  written: Bool?;
    }
    
    let largeBlob: AuthenticationExtensionsLargeBlobOutputs?
}

/**
    Branded types to make it clearer what the user should input
*/
typealias COSEAlgorithmIdentifier = Int
typealias BufferSource = Data
typealias Base64URLString = String

/**
    String extension to help with base64-url encoding
*/
extension String {
    // Encode a string to Base64 encoded string
    // Convert the string to data, then encode the data with base64EncodedString()
    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }

    // Decode a Base64 string
    // Convert it to data, then create a string from the decoded data
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
/**
    Data extension to enable base64-url encoding & decoding
*/
public extension Data {
    init?(base64URLEncoded input: String) {
        var base64 = input
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        self.init(base64Encoded: base64)
    }

    internal func toBase64URLEncodedString() -> Base64URLString {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
}
