import AuthenticationServices
import ExpoModulesCore
import Foundation

protocol PasskeyResultHandler {
    func onSuccessRegistration(_ data: RegistrationResponseJSON)
    func onSuccessAccountCreation(_ data: AccountCreationResponseJSON)
    func onSuccessAuthentication(_ data: AuthenticationResponseJSON)
    func onFailure(_ error: Error)
}

class PasskeyDelegate: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{
    private let handler: PasskeyResultHandler

    init(handler: PasskeyResultHandler) {
        self.handler = handler
    }

    // Perform the authorization request for a given ASAuthorizationController instance
    @available(iOS 15.0, *)
    func performAuthForController(controller: ASAuthorizationController) {
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
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
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if #available(iOS 26.0, *),
            let credential =
                authorization.credential as? ASAuthorizationAccountCreationPlatformPublicKeyCredential
        {
            guard let registrationResult = createPlatformRegistrationResult(
                from: credential.credentialRegistration)
            else {
                return
            }

            let accountCreationResult = AccountCreationResponseJSON(
                id: Field.init(wrappedValue: registrationResult.id),
                rawId: Field.init(wrappedValue: registrationResult.rawId),
                response: Field.init(wrappedValue: registrationResult.response),
                account: Field.init(
                    wrappedValue: AccountCreationDetailsJSON(
                        contactIdentifier: Field.init(
                            wrappedValue: getContactIdentifier(from: credential.contactIdentifier)),
                        name: Field.init(wrappedValue: getName(from: credential.name))
                    )),
                clientExtensionResults: Field.init(
                    wrappedValue: registrationResult.clientExtensionResults)
            )

            handler.onSuccessAccountCreation(accountCreationResult)
            return
        }

        switch authorization.credential {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            guard let result = createPlatformRegistrationResult(from: credential) else {
                return
            }

            handler.onSuccessRegistration(result)

        case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialRegistration:
            guard credential.rawAttestationObject != nil else {
                handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
                return
            }

            let response = AuthenticatorAttestationResponseJSON(
                clientDataJSON: Field.init(
                    wrappedValue: credential.rawClientDataJSON.toBase64URLEncodedString()),
                publicKey: Field.init(
                    wrappedValue: getPublicKey(from: credential.rawAttestationObject!)?
                        .toBase64URLEncodedString()),
                attestationObject: Field.init(
                    wrappedValue: credential.rawAttestationObject!.toBase64URLEncodedString())
            )

            let registrationResult = RegistrationResponseJSON(
                id: Field.init(wrappedValue: credential.credentialID.toBase64URLEncodedString()),
                rawId: Field.init(wrappedValue: credential.credentialID.toBase64URLEncodedString()),
                response: Field.init(wrappedValue: response)
            )

            handler.onSuccessRegistration(registrationResult)

        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON? =
                AuthenticationExtensionsLargeBlobOutputsJSON()
            if #available(iOS 17.0, *), let result = credential.largeBlob?.result {
                switch result {
                case .read(data: let blobData):
                    largeBlob?.blob = blobData?.toBase64URLEncodedString()
                case .write(success: let successfullyWritten):
                    largeBlob?.written = successfullyWritten
                @unknown default: break
                }
            }

            var prf: AuthenticationExtensionsPRFOutputsJSON?
            if #available(iOS 18.0, *) {
                prf = credential.prf.map {
                    AuthenticationExtensionsPRFOutputsJSON(
                        results: Field.init(
                            wrappedValue: AuthenticationExtensionsPRFValuesJSON(
                                first: Field.init(wrappedValue: $0.first.serialize()),
                                second: Field.init(wrappedValue: $0.second.serialize())
                            )
                        )
                    )
                }
            }

            let clientExtensionResults = AuthenticationExtensionsClientOutputsJSON(
                largeBlob: Field.init(wrappedValue: largeBlob),
                prf: Field.init(wrappedValue: prf)
            )

            let response = AuthenticatorAssertionResponseJSON(
                authenticatorData: Field.init(
                    wrappedValue: credential.rawAuthenticatorData.toBase64URLEncodedString()),
                clientDataJSON: Field.init(
                    wrappedValue: credential.rawClientDataJSON.toBase64URLEncodedString()),
                signature: Field.init(
                    wrappedValue: credential.signature!.toBase64URLEncodedString()),
                userHandle: Field.init(wrappedValue: credential.userID!.toBase64URLEncodedString())
            )

            let assertionResult = AuthenticationResponseJSON(
                id: Field.init(wrappedValue: credential.credentialID.toBase64URLEncodedString()),
                rawId: Field.init(wrappedValue: credential.credentialID.toBase64URLEncodedString()),
                response: Field.init(wrappedValue: response),
                clientExtensionResults: Field.init(wrappedValue: clientExtensionResults)
            )

            handler.onSuccessAuthentication(assertionResult)

        case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialAssertion:
            let response = AuthenticatorAssertionResponseJSON(
                authenticatorData: Field.init(
                    wrappedValue: credential.rawAuthenticatorData.toBase64URLEncodedString()),
                clientDataJSON: Field.init(
                    wrappedValue: credential.rawClientDataJSON.toBase64URLEncodedString()),
                signature: Field.init(
                    wrappedValue: credential.signature!.toBase64URLEncodedString()),
                userHandle: Field.init(wrappedValue: credential.userID!.toBase64URLEncodedString())
            )

            let assertionResult = AuthenticationResponseJSON(
                id: Field.init(wrappedValue: credential.credentialID.toBase64URLEncodedString()),
                rawId: Field.init(wrappedValue: credential.credentialID.toBase64URLEncodedString()),
                response: Field.init(wrappedValue: response)
            )

            handler.onSuccessAuthentication(assertionResult)
        default:
            handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
        }
    }

    @available(iOS 15.0, *)
    private func createPlatformRegistrationResult(
        from credential: ASAuthorizationPlatformPublicKeyCredentialRegistration
    ) -> RegistrationResponseJSON? {
        guard let attestationObject = credential.rawAttestationObject else {
            handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
            return nil
        }

        var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON?
        if #available(iOS 17.0, *) {
            largeBlob = AuthenticationExtensionsLargeBlobOutputsJSON(
                supported: Field.init(wrappedValue: credential.largeBlob?.isSupported)
            )
        }

        var prf: AuthenticationExtensionsPRFOutputsJSON?
        if #available(iOS 18.0, *) {
            prf = credential.prf.flatMap { it in
                AuthenticationExtensionsPRFOutputsJSON(
                    enabled: Field.init(wrappedValue: it.isSupported),
                    results: Field.init(
                        wrappedValue: it.first.map { first in
                            AuthenticationExtensionsPRFValuesJSON(
                                first: Field.init(wrappedValue: first.serialize()),
                                second: Field.init(wrappedValue: it.second.serialize()))
                        }
                    )
                )
            }
        }

        let clientExtensionResults = AuthenticationExtensionsClientOutputsJSON(
            largeBlob: Field.init(wrappedValue: largeBlob),
            prf: Field.init(wrappedValue: prf)
        )

        let response = AuthenticatorAttestationResponseJSON(
            clientDataJSON: Field.init(
                wrappedValue: credential.rawClientDataJSON.toBase64URLEncodedString()),
            publicKey: Field.init(
                wrappedValue: getPublicKey(from: attestationObject)?.toBase64URLEncodedString()),
            attestationObject: Field.init(
                wrappedValue: attestationObject.toBase64URLEncodedString())
        )

        return RegistrationResponseJSON(
            id: Field.init(wrappedValue: credential.credentialID.toBase64URLEncodedString()),
            rawId: Field.init(wrappedValue: credential.credentialID.toBase64URLEncodedString()),
            response: Field.init(wrappedValue: response),
            clientExtensionResults: Field.init(wrappedValue: clientExtensionResults)
        )
    }

    @available(iOS 26.0, *)
    private func getContactIdentifier(
        from identifier: ASContactIdentifier
    ) -> AccountCreationContactIdentifierJSON {
        switch identifier {
        case .email(let email):
            return AccountCreationContactIdentifierJSON(
                type: Field.init(wrappedValue: "email"),
                value: Field.init(wrappedValue: email.value)
            )
        case .phoneNumber(let phoneNumber):
            return AccountCreationContactIdentifierJSON(
                type: Field.init(wrappedValue: "phoneNumber"),
                value: Field.init(wrappedValue: phoneNumber.value)
            )
        }
    }

    @available(iOS 26.0, *)
    private func getName(
        from name: PersonNameComponents?
    ) -> PersonNameComponentsJSON? {
        guard let name else {
            return nil
        }

        return PersonNameComponentsJSON(
            namePrefix: Field.init(wrappedValue: name.namePrefix),
            givenName: Field.init(wrappedValue: name.givenName),
            middleName: Field.init(wrappedValue: name.middleName),
            familyName: Field.init(wrappedValue: name.familyName),
            nameSuffix: Field.init(wrappedValue: name.nameSuffix),
            nickname: Field.init(wrappedValue: name.nickname)
        )
    }
}
