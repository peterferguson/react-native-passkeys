// ! adapted from https://github.com/f-23/react-native-passkey/blob/fdcf7cf297debb247ada6317337767072158629c/ios/PasskeyDelegate.swift
import Foundation
import AuthenticationServices

struct PassKeyResult {
  var registrationResult: PassKeyRegistrationResult?
  var assertionResult: PassKeyAssertionResult?
}

struct PassKeyRegistrationResult {
  var credentialID: Data
  var rawAttestationObject: Data
  var rawClientDataJSON: Data
}

struct PassKeyAssertionResult {
  var credentialID: Data
  var rawAuthenticatorData: Data
  var rawClientDataJSON: Data
  var signature: Data
  var userID: Data
}

class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var _completion: (_ error: Error?, _ result: PassKeyResult?) -> Void;
  
    // Initializes delegate with a completion handler (callback function)
    init(completionHandler: @escaping (_ error: Error?, _ result: PassKeyResult?) -> Void) {
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
        return UIApplication.shared.keyWindow!;
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController,
                                        didCompleteWithAuthorization authorization: ASAuthorization) {
        // Check if Passkeys are supported on this OS version
        if #unavailable(iOS 15.0) {
            throw NotSupportedException()
        }

        switch (authorization.credential) {
        case is ASAuthorizationPlatformPublicKeyCredentialRegistration, is ASAuthorizationSecurityKeyPublicKeyCredentialRegistration: 
            if !authorization.credential.rawAttestationObject {
                throw AuthorizationFailedException()
            }
            let registrationResult = PassKeyRegistrationResult(credentialID: authorization.credential.credentialID,
                                                                rawAttestationObject: authorization.credential.rawAttestationObject,
                                                                rawClientDataJSON: authorization.credential.rawClientDataJSON)
            return PassKeyResult(registrationResult: registrationResult)
        case is ASAuthorizationPlatformPublicKeyCredentialAssertion, is ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
            let assertionResult = PassKeyAssertionResult(credentialID: authorization.credential.credentialID,
                                                            rawAuthenticatorData: authorization.credential.rawAuthenticatorData,
                                                            rawClientDataJSON: authorization.credential.rawClientDataJSON,
                                                            signature: authorization.credential.signature,
                                                            userID: authorization.credential.userID);
            return PassKeyResult(assertionResult: assertionResult)
        default:
            throw AuthorizationFailedException()
        }
    }
}
