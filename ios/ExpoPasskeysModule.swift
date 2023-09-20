import AuthenticationServices
import ExpoModulesCore
import LocalAuthentication


final public class ExpoPasskeysModule: Module {

  var passkeyDelegate: PasskeyDelegate?
  let onMessageEventName: String = "onMessage"

  public func definition() -> ModuleDefinition {
    Name("ExpoPasskeys")

    Events(self.onMessageEventName)

    Function("isSupported") { () -> Bool in
      if #available(iOS 15.0, *) {
        return true
      } else {
        return false
      }
    }

    Function("isAutoFillAvailable") { () -> Bool in
      return false
    }

//  AsyncFunction("get") {
//      (request: PublicKeyCredentialRequestOptions) throws -> PublicKeyCredentialRequestResponse in {
//          // TODO: implement me
//          throw NotSupportedException()
//      }
//  }

    AsyncFunction("create") { (request: PublicKeyCredentialCreationOptions, promise: Promise) throws in
        if #unavailable(iOS 15.0) {
            throw NotSupportedException()
        }

        if LAContext().biometricType == .none {
            throw BiometricException()
        }
        
        guard let challengeData: Data = Data(base64URLEncoded: request.challenge) else {
            throw InvalidChallengeException()
        }
        
//        if !request.user.id.isEmpty {
//            throw MissingUserIdException()
//        }
        
        guard let userId: Data = Data(base64URLEncoded: request.user.id) else {
            throw InvalidUserIdException()
        }
        
        let authController: ASAuthorizationController;
//        let securityKeyRegistrationRequest: ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequest?
        let platformKeyRegistrationRequest: ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest?
        
//        // - AuthenticatorAttachment.crossPlatform indicates that a security key should be used
//        // TODO: use the helper on the Authenticator Attachment enum?
//        if let isSecurityKey: Bool = request.authenticatorSelection.authenticatorAttachment == AuthenticatorAttachment.crossPlatform {
//            securityKeyRegistrationRequest = prepareCrossPlatformAuthorizationRequest(challenge: challengeData,
//                                                                                      userId: userId,
//                                                                                      request: request
//            )
//        } else {
            platformKeyRegistrationRequest = preparePlatformAuthorizationRequest(challenge: challengeData,
                                                                                 userId: userId,
                                                                                 request: request)
//        }

        if platformKeyRegistrationRequest != nil {
            authController = ASAuthorizationController(authorizationRequests: [platformKeyRegistrationRequest!]);
        } else {
            throw NotSupportedException()
        }
        
        self.passkeyDelegate = PasskeyDelegate { result in
          self.sendEvent(self.onMessageEventName, ["executing": "passkeyDelegate cb"])
     
                guard let passkeyResult = try? result.get() as PasskeyResult? else {
                self.sendEvent(self.onMessageEventName, ["error in delegate": result])
                //  handleASAuthorizationError(error: result.error);
                    return
              }
            
            // Check if the result object contains a valid registration result
            if let registrationResult = passkeyResult.registrationResult {
            // Return a NSDictionary instance with the received authorization data
            let authResponse: NSDictionary = [
              "rawAttestationObject": registrationResult.rawAttestationObject.toBase64URLEncodedString(),
              "rawClientDataJSON": registrationResult.rawClientDataJSON.toBase64URLEncodedString()
            ];

            let authResult: NSDictionary = [
              "credentialID": registrationResult.credentialID.toBase64URLEncodedString(),
              "response": authResponse
            ]
            promise.resolve(authResult)
          }
        }
      
      if let passkeyDelegate = self.passkeyDelegate {
          passkeyDelegate.performAuthForController(controller: authController);
      }
  }.runOnQueue(.main)
      
  }
}

//private func prepareCrossPlatformAuthorizationRequest(challenge: Data,
//                                                      userId: Data,
//                                                      request: PublicKeyCredentialCreationOptions) -> ASAuthorizationSecurityKeyPublicKeyCredentialAssertionRequest {
//
//  let securityKeyCredentialProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: request.rp!.id!)
//
//
//  let securityKeyRegistrationRequest =
//      securityKeyCredentialProvider.createCredentialRegistrationRequest(challenge: challenge,
//                                                                        displayName: request.user!.displayName,
//                                                                        name: request.user!.name,
//                                                                        userID: userId)
//
//  // Set request options to the Security Key provider
//  securityKeyRegistrationRequest.credentialParameters = request.pubKeyCredParams
//
//  if let residentCredPref = request.authenticatorSelection?.residentKey {
//      securityKeyRegistrationRequest.residentKeyPreference = parseResidentKeyPreference(residentCredPref)
//  }
//
//  if let userVerificationPref = request.authenticatorSelection?.userVerification {
//      securityKeyRegistrationRequest.userVerificationPreference = parseUserVerificationPreference(userVerificationPref)
//  }
//
//  if let rpAttestationPref = request.attestation {
//      securityKeyRegistrationRequest.attestationPreference = parseAttestationStatementPreference(rpAttestationPref)
//  }
//
//  if let excludedCredentials = request.excludeCredentials {
//      if !excludedCredentials.isEmpty {
//          securityKeyRegistrationRequest.excludedCredentials = credentialAttestationDescriptor(credentials: excludedCredentials)!
//      }
//  }
//
//
//  return securityKeyRegistrationRequest
//
//}

private func preparePlatformAuthorizationRequest(challenge: Data,
                                                 userId: Data,
                                                 request: PublicKeyCredentialCreationOptions) -> ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest {
  let platformKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier:  request.rp.id!)

  let platformKeyRegistrationRequest =
      platformKeyCredentialProvider.createCredentialRegistrationRequest(challenge: challenge,
//                                                                        displayName: request.user!.displayName,
                                                                        name: request.user.name,
                                                                        userID: userId)

  return platformKeyRegistrationRequest
}


// ! adapted from https://github.com/f-23/react-native-passkey/blob/fdcf7cf297debb247ada6317337767072158629c/ios/Passkey.swift#L138C55-L138C55
func handleASAuthorizationError(error: Error) throws -> Void {
  let errorCode = (error as NSError).code;
  switch errorCode {
  case 1001:
    throw UserCancelledException()
  case 1004:
      throw PasskeyRequestFailedException(name: "PasskeyRequestFailedException", description: error.localizedDescription)
  case 4004:
    throw NotConfiguredException()
  default:
    throw UnknownException()
  }
}

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
    }

    var biometricType: BiometricType {
        var error: NSError?

        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Capture these recoverable error thru Crashlytics
            return .none
        }

        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}

