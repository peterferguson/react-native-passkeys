// ! adapted from https://github.com/f-23/react-native-passkey/blob/fdcf7cf297debb247ada6317337767072158629c/ios/PasskeyDelegate.swift
import Foundation
import AuthenticationServices

protocol PasskeyResultHandler {
  func onSuccess(_ data: PasskeyResult)
  func onFailure(_ error: Error)
}

struct PasskeyResult {
  var registrationResult: PasskeyRegistrationResult?
  var assertionResult: PasskeyAssertionResult?
}

// TODO: these are returned to RN so should be records & converted to Base64URL
struct PasskeyRegistrationResult {
  var credentialID: Data
  var rawAttestationObject: Data
  var rawClientDataJSON: Data
}

struct PasskeyAssertionResult {
  var credentialID: Data
  var rawAuthenticatorData: Data
  var rawClientDataJSON: Data
  var signature: Data
  var userID: Data
  var largeBlob: Data?
}


class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding  {
    private let handler: PasskeyResultHandler 

    init(handler: PasskeyResultHandler) {
        self.handler = handler
    }

    // Perform the authorization request for a given ASAuthorizationController instance
    @available(iOS 15.0, *)
    func performAuthForController(controller: ASAuthorizationController) {
        controller.delegate = self;
        controller.presentationContextProvider = self;
        controller.performRequests();
    }

    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow ?? ASPresentationAnchor()
    }

    
    @available(iOS 13.0, *)
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        handler.onFailure(error)
    }

    @available(iOS 15.0, *)
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {

        switch (authorization.credential) {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            // , is ASAuthorizationSecurityKeyPublicKeyCredentialRegistration:
            if credential.rawAttestationObject == nil {
                handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
            }
            
            var registrationResult = PasskeyRegistrationResult(credentialID: credential.credentialID,
                                                               rawAttestationObject: credential.rawAttestationObject!,
                                                               rawClientDataJSON: credential.rawClientDataJSON)
            // TODO: can we return if it was written
            //            if #available(iOS 17.0, *), ((credential.largeBlob?.isSupported) != nil) {
            //                if let largeBlob = credential.largeBlob {
            //                    registrationResult.largeBlob = largeBlob
            //                }
            //            }
            
            
            handler.onSuccess((PasskeyResult(registrationResult: registrationResult)))
            
        case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialRegistration:
            if credential.rawAttestationObject == nil {
                handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
            }
            let registrationResult = PasskeyRegistrationResult(credentialID: credential.credentialID,
                                                               rawAttestationObject: credential.rawAttestationObject!,
                                                               rawClientDataJSON: credential.rawClientDataJSON)
            handler.onSuccess((PasskeyResult(registrationResult: registrationResult)))
            
        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            var largeBlob: Data?
            if #available(iOS 17.0, *), let result = credential.largeBlob?.result {
                switch (result) {
                case .read(data: let blob):
                    largeBlob = blob
                case .write(success: _):break
                @unknown default: break
                }
            }
            
            let assertionResult = PasskeyAssertionResult(credentialID: credential.credentialID,
                                                         rawAuthenticatorData: credential.rawAuthenticatorData,
                                                         rawClientDataJSON: credential.rawClientDataJSON,
                                                         signature: credential.signature,
                                                         userID: credential.userID,
                                                         largeBlob: largeBlob);
            
            handler.onSuccess((PasskeyResult(assertionResult: assertionResult)))
            
        case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
            let assertionResult = PasskeyAssertionResult(credentialID: credential.credentialID,
                                                         rawAuthenticatorData: credential.rawAuthenticatorData,
                                                         rawClientDataJSON: credential.rawClientDataJSON,
                                                         signature: credential.signature,
                                                         userID: credential.userID);
            handler.onSuccess((PasskeyResult(assertionResult: assertionResult)))
        default:
            handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
        }
    }
}
