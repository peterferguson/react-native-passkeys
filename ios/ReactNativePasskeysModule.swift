import AuthenticationServices
import ExpoModulesCore
import LocalAuthentication

struct PasskeyContext {
  let passkeyDelegate: PasskeyDelegate
  let promise: Promise
}

final public class ReactNativePasskeysModule: Module, PasskeyResultHandler {
  private var passkeyContext: PasskeyContext?

  public func definition() -> ModuleDefinition {
    Name("ReactNativePasskeys")

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

    AsyncFunction("get") { (request: PublicKeyCredentialRequestOptions, promise: Promise) throws in
        do { 
            // - all the throws are already in the helper `isAvailable` so we don't need to do anything
            // ? this seems like a code smell ... what is the best way to do this
            let _ = try isAvailable() 
        } 
        catch let error {
            throw error
        }
        let passkeyDelegate = PasskeyDelegate(handler: self)
        passkeyContext = PasskeyContext(passkeyDelegate: passkeyDelegate, promise: promise)
        
        guard let challengeData: Data = Data(base64URLEncoded: request.challenge) else {
            throw InvalidChallengeException()
        }

        let crossPlatformKeyAssertionRequest = prepareCrossPlatformAssertionRequest(challenge: challengeData, request: request)
        let platformKeyAssertionRequest = preparePlatformAssertionRequest(challenge: challengeData, request: request)
        
        let authController = ASAuthorizationController(authorizationRequests: [platformKeyAssertionRequest, crossPlatformKeyAssertionRequest])
    
        passkeyDelegate.performAuthForController(controller: authController);
    }.runOnQueue(.main)

    AsyncFunction("create") { (request: PublicKeyCredentialCreationOptions, promise: Promise) throws in
        do { 
            // - all the throws are already in the helper `isAvailable` so we don't need to do anything
            // ? this seems like a code smell ... what is the best way to do this
            let _ = try isAvailable() 
        } 
        catch let error {
            throw error
        }

        let passkeyDelegate = PasskeyDelegate(handler: self)
        let context = PasskeyContext(passkeyDelegate: passkeyDelegate, promise: promise)
        
        guard let challengeData: Data = Data(base64URLEncoded: request.challenge) else {
            throw InvalidChallengeException()
        }
        
        guard let userId: Data = Data(base64URLEncoded: request.user.id) else {
            throw InvalidUserIdException()
        }
        
        var crossPlatformKeyRegistrationRequest: ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequest?
        var platformKeyRegistrationRequest: ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest?
        
        if request.authenticatorSelection?.authenticatorAttachment == AuthenticatorAttachment.crossPlatform {
            crossPlatformKeyRegistrationRequest = prepareCrossPlatformRegistrationRequest(challenge: challengeData,
                                                                                          userId: userId,
                                                                                          request: request)
        } else {
            platformKeyRegistrationRequest = preparePlatformRegistrationRequest(challenge: challengeData,
                                                                                userId: userId,
                                                                                request: request)
        }

        let authController: ASAuthorizationController;

        if platformKeyRegistrationRequest != nil {
            authController = ASAuthorizationController(authorizationRequests: [platformKeyRegistrationRequest!]);
        } else {
            authController = ASAuthorizationController(authorizationRequests: [crossPlatformKeyRegistrationRequest!])
        }

        passkeyContext = context
        
        context.passkeyDelegate.performAuthForController(controller: authController);
    }.runOnQueue(.main)
      
  }

  private func isAvailable() throws -> Bool {
    if #unavailable(iOS 15.0) {
        throw NotSupportedException()
    }

    if passkeyContext != nil {
        throw PendingPasskeyRequestException()
    }

    if LAContext().biometricType == .none {
        throw BiometricException()
    }

    return true
  }

  internal func onSuccess(_ data: PublicKeyCredentialJSON) {
    guard let promise = passkeyContext?.promise else {
        log.error("Passkey context has been lost")
        return
    }
    passkeyContext = nil

    if let registrationResult: RegistrationResponseJSON = data.get() {
      promise.resolve(registrationResult)
      return
    }
    
    if let assertionResult: AuthenticationResponseJSON = data.get() {
      promise.resolve(assertionResult)
      return
    }
  }

  internal func onFailure(_ error: Error) {
    guard let promise = passkeyContext?.promise else {
      log.error("Passkey context has been lost")
      return
    }
    passkeyContext = nil
    promise.reject(handleASAuthorizationError(errorCode:(error as NSError).code, 
                                              localizedDescription: error.localizedDescription))
  }

}

private func prepareCrossPlatformRegistrationRequest(challenge: Data,
                                                     userId: Data,
                                                     request: PublicKeyCredentialCreationOptions) -> ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequest {

  let crossPlatformCredentialProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(relyingPartyIdentifier: request.rp.id!)


  let crossPlatformRegistrationRequest =
      crossPlatformCredentialProvider.createCredentialRegistrationRequest(challenge: challenge,
                                                                          displayName: request.user.displayName,
                                                                          name: request.user.name,
                                                                          userID: userId)

  // Set request options to the Security Key provider
  crossPlatformRegistrationRequest.credentialParameters = request.pubKeyCredParams.map({ $0.appleise() })

  if let residentCredPref = request.authenticatorSelection?.residentKey {
      crossPlatformRegistrationRequest.residentKeyPreference = residentCredPref.appleise()
  }

  if let userVerificationPref = request.authenticatorSelection?.userVerification {
      crossPlatformRegistrationRequest.userVerificationPreference = userVerificationPref.appleise()
  }

  if let rpAttestationPref = request.attestation {
      crossPlatformRegistrationRequest.attestationPreference = rpAttestationPref.appleise()
  }

  if let excludedCredentials = request.excludeCredentials {
      if !excludedCredentials.isEmpty {
        if #available(iOS 17.4, *) {
            crossPlatformRegistrationRequest.excludedCredentials = excludedCredentials.map({ $0.getCrossPlatformDescriptor() })
        }
      }
  }

  return crossPlatformRegistrationRequest

}

private func preparePlatformRegistrationRequest(challenge: Data,
                                                userId: Data,
                                                request: PublicKeyCredentialCreationOptions) -> ASAuthorizationPlatformPublicKeyCredentialRegistrationRequest {
  let platformKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
    relyingPartyIdentifier: request.rp.id!)

  let platformKeyRegistrationRequest =
      platformKeyCredentialProvider.createCredentialRegistrationRequest(challenge: challenge,
                                                                        name: request.user.name,
                                                                        userID: userId)
    
//    if let residentCredPref = request.authenticatorSelection?.residentKey {
//        platformKeyRegistrationRequest.residentKeyPreference = residentCredPref.appleise()
//    }
    
    // TODO: integrate this
    // platformKeyRegistrationRequest.shouldShowHybridTransport
    
    if #available(iOS 17, *) {
         switch (request.extensions?.largeBlob?.support) {
         case .preferred:
             platformKeyRegistrationRequest.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobRegistrationInput.supportPreferred
         case .required:
             platformKeyRegistrationRequest.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobRegistrationInput.supportRequired
         case .none:
              break
         }
    }

    if let userVerificationPref = request.authenticatorSelection?.userVerification {
        platformKeyRegistrationRequest.userVerificationPreference = userVerificationPref.appleise()
    }

    if let rpAttestationPref = request.attestation {
        platformKeyRegistrationRequest.attestationPreference = rpAttestationPref.appleise()
    }

    if let excludedCredentials = request.excludeCredentials {
        if !excludedCredentials.isEmpty {
            if #available(iOS 17.4, *) {
                platformKeyRegistrationRequest.excludedCredentials = excludedCredentials.map({ $0.getPlatformDescriptor() })
            }
        }
    }
    
  return platformKeyRegistrationRequest
}

private func prepareCrossPlatformAssertionRequest(challenge: Data, 
                                                  request: PublicKeyCredentialRequestOptions) -> ASAuthorizationSecurityKeyPublicKeyCredentialAssertionRequest {

    let crossPlatformCredentialProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(
        relyingPartyIdentifier: request.rpId)


    let crossPlatformAssertionRequest: ASAuthorizationSecurityKeyPublicKeyCredentialAssertionRequest =
      crossPlatformCredentialProvider.createCredentialAssertionRequest(challenge: challenge)

    if let allowCredentials = request.allowCredentials {
        if !allowCredentials.isEmpty {
          crossPlatformAssertionRequest.allowedCredentials =  allowCredentials.map({ $0.getCrossPlatformDescriptor() })
        }
    }

  return crossPlatformAssertionRequest
}

private func preparePlatformAssertionRequest(challenge: Data, request: PublicKeyCredentialRequestOptions) -> ASAuthorizationPlatformPublicKeyCredentialAssertionRequest {

    let platformKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
        relyingPartyIdentifier: request.rpId)


    let platformKeyAssertionRequest: ASAuthorizationPlatformPublicKeyCredentialAssertionRequest =
      platformKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)
    
    
    if #available(iOS 17, *) {
        if (request.extensions?.largeBlob?.read == true) {
            platformKeyAssertionRequest.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobAssertionInput.read
        }
        
        else if let blob = request.extensions?.largeBlob?.write {
            platformKeyAssertionRequest.largeBlob = ASAuthorizationPublicKeyCredentialLargeBlobAssertionInput.write(
                Data(base64URLEncoded: blob)!
            )
        }
    }
    
    // TODO: integrate this
    // platformKeyAssertionRequest.shouldShowHybridTransport
    
    if let userVerificationPref = request.userVerification {
        platformKeyAssertionRequest.userVerificationPreference = userVerificationPref.appleise()
    }


    if let allowCredentials = request.allowCredentials {
        if !allowCredentials.isEmpty {
          platformKeyAssertionRequest.allowedCredentials = allowCredentials.map({ $0.getPlatformDescriptor() })
        }
    }

  return platformKeyAssertionRequest
}



func handleASAuthorizationError(errorCode: Int, localizedDescription: String = "") -> Exception {
  switch errorCode {
  case 1001:
    return UserCancelledException(name: "UserCancelledException", description: localizedDescription)
  case 1004:
      return PasskeyRequestFailedException(name: "PasskeyRequestFailedException", description: localizedDescription)
  case 4004:
    return NotConfiguredException(name: "NotConfiguredException", description: localizedDescription)
  default:
     return UnknownException(name: "UnknownException", description: localizedDescription)
  }
}

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
        case opticID
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
            case .opticID:
                return .opticID
            @unknown default:
                return .none
            }
        } else {
            return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}

