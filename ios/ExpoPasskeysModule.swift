import AuthenticationServices
import ExpoModulesCore

public class ExpoPasskeysModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoPasskeys")

    Function("isSupported") { 
      if #available(iOS 15.0, *) {
        return true
      } else {
        return false
      }
    }

    Function("isAutoFillAvailable") {
      return false
    }

    AsyncFunction("get", getPasskey)

    AsyncFunction("create", createPasskey)

  }

  private func getPasskey(request: PublicKeyCredentialCreationOptions) -> PublicKeyCredentialCreationResponse {
      if !self.isSupported {
        throw NotSupportedException()
      }

      guard let challengeData: Data = Data(base64URLEncoded: request.challenge!) else {
        throw InvalidChallengeException()
      }

      guard let userId: Data = Data(base64URLEncoded: request.user.id!) else {
        throw InvalidUserIdException()
      }


      return "get world! 👋"
  }

  // ! adapted from https://github.com/f-23/react-native-passkey/blob/fdcf7cf297debb247ada6317337767072158629c/ios/Passkey.swift#L138C55-L138C55
  // Handles ASAuthorization error codes
  func handleErrorCode(error: Error) -> PassKeyError {
    let errorCode = (error as NSError).code;
    switch errorCode {
      case 1001:
        return PassKeyError.cancelled;
      case 1004:
        return PassKeyError.requestFailed;
      case 4004:
        return PassKeyError.notConfigured;
      default:
        return PassKeyError.unknown;
    }
  }
}

private class NotSupportedException: Exception {
  override var reason: String {
    "Paskeys are not supported on this iOS version. Please use iOS 15 or above"
  }
}

private class UserCancelledException: Exception {
  override var reason: String {
    "User cancelled the passkey interaction"
  }
}

private class InvalidChallengeException: Exception {
  override var reason: String {
    "The provided challenge was invalid"
  }
}

private class InvalidUserIdException: Exception {
  override var reason: String {
    "The provided userId was invalid"
  }
}

// enum PassKeyError: String, Error {
//   case requestFailed = "RequestFailed"
//   case invalidChallenge = "InvalidChallenge"
//   case notConfigured = "NotConfigured"
//   case unknown = "UnknownError"
// }


// - preferences for security keys


// // Parse the relying party's attestation statement preference response and return a ASAuthorizationPublicKeyCredentialAttestationKind
// // Acceptable values: direct, indirect, or enterprise
// func attestationStatementPreference(_ rpAttestationStatementPreference: String) -> ASAuthorizationPublicKeyCredentialAttestationKind {
//     switch rpAttestationStatementPreference {
//         case "direct":
//             return ASAuthorizationPublicKeyCredentialAttestationKind.direct
//         case "indirect":
//             return ASAuthorizationPublicKeyCredentialAttestationKind.indirect
//         case "enterprise":
//             return ASAuthorizationPublicKeyCredentialAttestationKind.enterprise
//         default:
//             return ASAuthorizationPublicKeyCredentialAttestationKind.direct
//     }
// }

// // Parse the relying party user verification preference response and return a ASAuthorizationPublicKeyCredentialUserVerificationPreference
// // Acceptable UV preferences: discouraged, preferred, or required
// func userVerificationPreference(_ userVerificationPreference: String) -> ASAuthorizationPublicKeyCredentialUserVerificationPreference {
//   switch userVerificationPreference {
//       case "discouraged":
//           return ASAuthorizationPublicKeyCredentialUserVerificationPreference.discouraged
//       case "preferred":
//           return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
//       case "required":
//           return ASAuthorizationPublicKeyCredentialUserVerificationPreference.required
//       default:
//           return ASAuthorizationPublicKeyCredentialUserVerificationPreference.preferred
//   }
// }

// // Parse the relying party's resident credential (aka "discoverable credential") preference response and return a ASAuthorizationPublicKeyCredentialResidentKeyPreference
// // Acceptable UV preferences: discouraged, preferred, or required
// func residentKeyPreference(_ residentCredPreference: String) -> ASAuthorizationPublicKeyCredentialResidentKeyPreference {
//     switch residentCredPreference {
//         case "discouraged":
//             return ASAuthorizationPublicKeyCredentialResidentKeyPreference.discouraged
//         case "preferred":
//             return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
//         case "required":
//             return ASAuthorizationPublicKeyCredentialResidentKeyPreference.required
//         default:
//             return ASAuthorizationPublicKeyCredentialResidentKeyPreference.preferred
//     }
// }

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