import Foundation
import AuthenticationServices

// Perform the authorization request for a given ASAuthorizationController instance
@available(iOS 15.0, *)
internal func performAuthForController(controller: ASAuthorizationController) {
    controller.delegate = self;
    controller.presentationContextProvider = self;
    controller.performRequests();
}

@available(iOS 13.0, *)
internal func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return UIApplication.shared.keyWindow!;
}

@available(iOS 13.0, *)
internal func authorizationController(controller: ASAuthorizationController,
                                      didCompleteWithAuthorization authorization: ASAuthorization) {
    // Check if Passkeys are supported on this OS version
    if #available(iOS 15.0, *) {
        /** We need to determine whether the request was a registration or authentication request and if a security key was used or not*/
        
        // Request was a registration request
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            handlePlatformPublicKeyRegistrationResponse(credential: credential)
        //Request was an authentication request
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            handlePlatformPublicKeyAssertionResponse(credential: credential)
        // Request was a registration request with security key
        } else if let credential = authorization.credential as? ASAuthorizationSecurityKeyPublicKeyCredentialRegistration {
            handleSecurityKeyPublicKeyRegistrationResponse(credential: credential)
        // Request was an authentication request with security key
        } else if let credential = authorization.credential as? ASAuthorizationSecurityKeyPublicKeyCredentialAssertion {
            handleSecurityKeyPublicKeyAssertionResponse(credential: credential)
        } else {
            throw AuthorizationFailedException()
        }
    } else {
        // Authorization credential was malformed, throw an error
        throw NotSupportedException()
    }
}

@available(iOS 15.0, *)
internal func handlePlatformPublicKeyRegistrationResponse(credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) -> Void {
    if let rawAttestationObject = credential.rawAttestationObject {
        // Parse the authorization credential and resolve the callback
        let registrationResult = PassKeyRegistrationResult(credentialID: credential.credentialID,
                                                            rawAttestationObject: rawAttestationObject,
                                                            rawClientDataJSON: credential.rawClientDataJSON);
            return PassKeyResult(registrationResult: registrationResult)
    } else {
        throw AuthorizationFailedException()
    }
}

@available(iOS 15.0, *)
internal func handleSecurityKeyPublicKeyRegistrationResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialRegistration) -> Void {
    if let rawAttestationObject = credential.rawAttestationObject {
        // Parse the authorization credential and resolve the callback
        let registrationResult = PassKeyRegistrationResult(credentialID: credential.credentialID,
                                                            rawAttestationObject: rawAttestationObject,
                                                            rawClientDataJSON: credential.rawClientDataJSON);
        return PassKeyResult(registrationResult: registrationResult)
    } else {
        throw AuthorizationFailedException()
    }
}

@available(iOS 15.0, *)
internal func handlePlatformPublicKeyAssertionResponse(credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) -> Void {
    // Parse the authorization credential and resolve the callback
    let assertionResult = PassKeyAssertionResult(credentialID: credential.credentialID,
                                                    rawAuthenticatorData: credential.rawAuthenticatorData,
                                                    rawClientDataJSON: credential.rawClientDataJSON,
                                                    signature: credential.signature,
                                                    userID: credential.userID);
    return PassKeyResult(assertionResult: assertionResult)
}


@available(iOS 15.0, *)
internal func handleSecurityKeyPublicKeyAssertionResponse(credential: ASAuthorizationSecurityKeyPublicKeyCredentialAssertion) -> Void {
    // Parse the authorization credential and resolve the callback
    let assertionResult = PassKeyAssertionResult(credentialID: credential.credentialID,
                                                 rawAuthenticatorData: credential.rawAuthenticatorData,
                                                 rawClientDataJSON: credential.rawClientDataJSON,
                                                 signature: credential.signature,
                                                 userID: credential.userID);
    return PassKeyResult(assertionResult: assertionResult)
}