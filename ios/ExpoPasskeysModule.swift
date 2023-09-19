import AuthenticationServices
import ExpoModulesCore

public class ExpoPasskeysModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoPasskeys")

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

//      AsyncFunction("get") {
//          (request: PublicKeyCredentialRequestOptions) throws -> PublicKeyCredentialRequestResponse in {
//              // TODO: implement me
//              throw NotSupportedException()
//          }
//      }

      AsyncFunction("create") { (request: PublicKeyCredentialCreationOptions, promise: Promise) throws in {
          if #unavailable(iOS 15.0) {
              throw NotSupportedException()
          }
          
          guard let challengeData: Data = Data(base64URLEncoded: request.challenge) else {
              throw InvalidChallengeException()
          }
          
          if !request.user.id.isEmpty {
              throw MissingUserIdException()
          }
          
          guard let userId: Data = Data(base64URLEncoded: request.user.id) else {
              throw InvalidUserIdException()
          }
          
          let authController: ASAuthorizationController;
//          let securityKeyRegistrationRequest: ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequest?
          let platformKeyRegistrationRequest: ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest?
          
//          // - AuthenticatorAttachment.crossPlatform indicates that a security key should be used
//          // TODO: use the helper on the Authenticator Attachment enum?
//          if let isSecurityKey: Bool = request.authenticatorSelection.authenticatorAttachment == AuthenticatorAttachment.crossPlatform {
//              securityKeyRegistrationRequest = prepareCrossPlatformAuthorizationRequest(challenge: challengeData,
//                                                                                        userId: userId,
//                                                                                        request: request
//              )
//          } else {
              platformKeyRegistrationRequest = preparePlatformAuthorizationRequest(challenge: challengeData,
                                                                                   userId: userId,
                                                                                   request: request)
//          }

          if platformKeyRegistrationRequest != nil {
              authController = ASAuthorizationController(authorizationRequests: [platformKeyRegistrationRequest!]);
          } else {
              throw NotSupportedException()
          }
          
          let passKeyDelegate =  try! preparePasskeyDelegate(promise: promise)
          
          // Perform the authorization request
          passKeyDelegate.performAuthForController(controller: authController);
          
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
      throw PasskeyRequestFailedException()
    case 4004:
      throw NotConfiguredException()
    default:
      throw UnknownException()
  }
}

private func preparePasskeyDelegate(promise: Promise) throws -> PasskeyDelegate {
  return PasskeyDelegate { error, result in
        if error != nil {
          try! handleASAuthorizationError(error: error!);
        }

        // Check if the result object contains a valid registration result
        if let registrationResult = result?.registrationResult {
          // Return a NSDictionary instance with the received authorization data
          let authResponse: NSDictionary = [
            "rawAttestationObject": registrationResult.rawAttestationObject.base64EncodedString(),
            "rawClientDataJSON": registrationResult.rawClientDataJSON.base64EncodedString()
          ];

          let authResult: NSDictionary = [
            "credentialID": registrationResult.credentialID.base64EncodedString(),
            "response": authResponse
          ]
          promise.resolve(authResult)
        } else {
          throw PasskeyRequestFailedException()
        }
      }

}

