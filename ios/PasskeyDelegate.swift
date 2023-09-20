// ! adapted from https://github.com/f-23/react-native-passkey/blob/fdcf7cf297debb247ada6317337767072158629c/ios/PasskeyDelegate.swift
import Foundation
import AuthenticationServices

struct PasskeyResult {
  var registrationResult: PasskeyRegistrationResult?
  var assertionResult: PasskeyAssertionResult?
}

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
}


class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding  {

    typealias CompletionHandler = (Result<PasskeyResult, Error>) -> Void

    private var _completion: CompletionHandler;
  
    // Initializes delegate with a completion handler (callback function)
    init(completionHandler: @escaping CompletionHandler) {
        self._completion = completionHandler;
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
        self._completion(.failure(error));
    }

    @available(iOS 15.0, *)
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {

        switch (authorization.credential) {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            // , is ASAuthorizationSecurityKeyPublicKeyCredentialRegistration:
            if credential.rawAttestationObject == nil {
                self._completion(.failure(ASAuthorizationError(ASAuthorizationError.Code.failed)))
            }
            let registrationResult = PasskeyRegistrationResult(credentialID: credential.credentialID,
                                                               rawAttestationObject: credential.rawAttestationObject!,
                                                               rawClientDataJSON: credential.rawClientDataJSON)
            self._completion(.success(PasskeyResult(registrationResult: registrationResult)))
            
        case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialRegistration:
            if credential.rawAttestationObject == nil {
                self._completion(.failure(ASAuthorizationError(ASAuthorizationError.Code.failed)))
            }
            let registrationResult = PasskeyRegistrationResult(credentialID: credential.credentialID,
                                                               rawAttestationObject: credential.rawAttestationObject!,
                                                               rawClientDataJSON: credential.rawClientDataJSON)
            self._completion(.success(PasskeyResult(registrationResult: registrationResult)))
            
        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            let assertionResult = PasskeyAssertionResult(credentialID: credential.credentialID,
                                                         rawAuthenticatorData: credential.rawAuthenticatorData,
                                                         rawClientDataJSON: credential.rawClientDataJSON,
                                                         signature: credential.signature,
                                                         userID: credential.userID);
            self._completion(.success(PasskeyResult(assertionResult: assertionResult)))
            
        case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
            let assertionResult = PasskeyAssertionResult(credentialID: credential.credentialID,
                                                         rawAuthenticatorData: credential.rawAuthenticatorData,
                                                         rawClientDataJSON: credential.rawClientDataJSON,
                                                         signature: credential.signature,
                                                         userID: credential.userID);
            self._completion(.success(PasskeyResult(assertionResult: assertionResult)))
        default:
            self._completion(.failure(ASAuthorizationError(ASAuthorizationError.Code.failed)))
        }
    }
}
