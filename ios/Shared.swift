import ExpoModulesCore
import AuthenticationServices

// - Enums 

internal enum AuthenticatorTransport: String {
    case ble = "ble"
    case hybrid = "hybrid"
    case internalTransport = "internal"
    case nfc = "nfc"
    case usb = "usb"
}


internal enum AuthenticatorAttachment: String {
    case platform = "platform"
    case crossPlatform = "cross-platform"
}

internal enum PublicKeyCredentialType: String {
    case publicKey = "public-key"
}

internal enum UserVerificationRequirement: String {
    case discouraged = "discouraged"
    case preferred = "preferred"
    case required = "required"
}

internal enum LargeBlobSupport: String {
    case preferred = "preferred"
    case required = "required"
}

internal enum AuthenticatorSelectionCriteria: String {
    case platform = "platform"
    case crossPlatform = "cross-platform"

    // - cross-platform marks that the user wants to select a security key
    var isSecurityKey: Bool {
        switch self {
            case .platform:
                return false
            case .crossPlatform:
                return true
        }
    }

}


// - Structs

internal struct PublicKeyCredentialRpEntity {
    let name: String
    let id: String?
}

internal struct PublicKeyCredentialUserEntity {
    let name: String
    let displayName: String
    let id: Base64URLString
}



internal struct PublicKeyCredentialDescriptor {
    let id: Base64URLString
    let transports: [AuthenticatorTransport]?
    let type: PublicKeyCredentialType
}


internal struct AuthenticationExtensionsClientInputs {
    struct AuthenticationExtensionsLargeBlobInputs {
        // - Only valid during registration.
        let support: LargeBlobSupport?
        
        // - A boolean that indicates that the Relying Party would like to fetch the previously-written blob associated with the asserted credential. Only valid during authentication.
        let read: Bool?
        
        // - An opaque byte string that the Relying Party wishes to store with the existing credential. Only valid during authentication.
        // - We impose that the data is passed as base64-url encoding to make better align the passing of data from RN to native code
        let write: Base64URLString?
    }
    
    // - only largeBlob extension is currently supported on iOS17
    let largeBlob: AuthenticationExtensionsLargeBlobInputs?
}

internal struct AuthenticationExtensionsClientOutputs {
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

// -  Branded types referenced in the interfaces
typealias COSEAlgorithmIdentifier = Int
typealias BufferSource = Data
typealias Base64URLString = String


// - preferences for security keys

// tODO: update these to match our enums or use the AS ones directly

func parseAttestationStatementPreference(_ rpAttestationStatementPreference: String) -> ASAuthorizationPublicKeyCredentialAttestationKind {
    switch rpAttestationStatementPreference {
        case "direct":
            return ASAuthorizationPublicKeyCredentialAttestationKind.direct
        case "indirect":
            return ASAuthorizationPublicKeyCredentialAttestationKind.indirect
        case "enterprise":
            return ASAuthorizationPublicKeyCredentialAttestationKind.enterprise
        default:
            return ASAuthorizationPublicKeyCredentialAttestationKind.direct
    }
}

func parseUserVerificationPreference(_ userVerificationPreference: String) -> ASAuthorizationPublicKeyCredentialUserVerificationPreference {
  switch userVerificationPreference {
      case "discouraged":
          return ASAuthorizationPublicKeyCredentialUserVerificationPreference.discouraged
      case "preferred":
          return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
      case "required":
          return ASAuthorizationPublicKeyCredentialUserVerificationPreference.required
      default:
          return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
  }
}

func parseResidentKeyPreference(_ residentCredPreference: String) -> ASAuthorizationPublicKeyCredentialResidentKeyPreference {
    switch residentCredPreference {
        case "discouraged":
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.discouraged
        case "preferred":
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
        case "required":
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.required
        default:
            return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
    }
}

func parseAuthenticatorTransport(_ transport: String) -> ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport? {
    switch (transport) {
    case "ble": 
        return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.bluetooth
    case "nfc": 
        return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.nfc
    case "usb": 
        return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.usb
    // - including these to be clear that they are not yet supported although they exist in the spec
    // case "hybrid": 
    // case "internal": 
    default: 
        return nil
    }
}

func parseCredentialAttestationDescriptor(credentials: [PublicKeyCredentialDescriptor]) -> [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor]? {
    if (credentials.isEmpty) { return nil }
    
    var publicKeyCredentials = [ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor]()
    
    for creds in credentials {
        var transports = creds.transports?.compactMap { parseAuthenticatorTransport($0.rawValue) } ?? ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported
        
        if (transports.isEmpty) {
            transports = ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport.allSupported
        }
        
        let cred = ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.init(credentialID: Data(base64URLEncoded: creds.id)!, transports: transports)
        
        publicKeyCredentials.append(cred)
    }
    
    return publicKeyCredentials
}


// - Encoding helpers

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

    func toBase64URLEncodedString() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
}
