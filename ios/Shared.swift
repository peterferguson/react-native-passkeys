import ExpoModulesCore

// - Enums 

/*
*  These enums are here to match the navigator.credentials api.
*  There where the values are supported they will be ...
*/
internal enum AuthenticatorTransport: String, EnumArgument {
    case ble = "ble"
    case hybrid = "hybrid"
    case internalTransport = "internal"
    case nfc = "nfc"
    case usb = "usb"
}


internal enum AuthenticatorAttachment: String, EnumArgument {
    case platform = "platform"
    case crossPlatform = "cross-platform"
}

internal enum PublicKeyCredentialType: String, EnumArgument {
    case publicKey = "public-key"
}

internal enum UserVerificationRequirement: String, EnumArgument {
    case discouraged = "discouraged"
    case preferred = "preferred"
    case required = "required"
}

internal enum AuthenticatorSelectionCriteria: String, EnumArgument {
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

internal struct PublicKeyCredentialDescriptor {
    let id: BufferSource
    let transports: [AuthenticatorTransport]?
    let type: PublicKeyCredentialType
}

// -  Branded types referenced in the interfaces

typealias COSEAlgorithmIdentifier = Int
typealias BufferSource = Data
typealias Base64URLString = String

