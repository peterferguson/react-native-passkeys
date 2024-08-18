import AuthenticationServices
import ExpoModulesCore
// ! adapted from https://github.com/f-23/react-native-passkey/blob/fdcf7cf297debb247ada6317337767072158629c/ios/PasskeyDelegate.swift
import Foundation
import SwiftCBOR

protocol PasskeyResultHandler {
    func onSuccess(_ data: PublicKeyCredentialJSON)
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

        switch authorization.credential {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            if credential.rawAttestationObject == nil {
                handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
            }

            var largeBlob: AuthenticationExtensionsLargeBlobOutputsJSON?
            if #available(iOS 17.0, *) {
                largeBlob = AuthenticationExtensionsLargeBlobOutputsJSON(
                    supported: Field.init(wrappedValue: credential.largeBlob?.isSupported)
                )
            }

            let clientExtensionResults = AuthenticationExtensionsClientOutputsJSON(
                largeBlob: Field.init(wrappedValue: largeBlob)
            )

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
                response: Field.init(wrappedValue: response),
                clientExtensionResults: Field.init(wrappedValue: clientExtensionResults)
            )

            handler.onSuccess(Either(registrationResult))

        case let credential as ASAuthorizationSecurityKeyPublicKeyCredentialRegistration:
            if credential.rawAttestationObject == nil {
                handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
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

            handler.onSuccess(Either(registrationResult))

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

            let clientExtensionResults = AuthenticationExtensionsClientOutputsJSON(
                largeBlob: Field.init(wrappedValue: largeBlob))

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

            handler.onSuccess(Either(assertionResult))

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

            handler.onSuccess(Either(assertionResult))
        default:
            handler.onFailure((ASAuthorizationError(ASAuthorizationError.Code.failed)))
        }
    }
}

func getPublicKey(from attestationObject: Data)
    -> Data?
{
    guard
        let cbor = try? CBOR.decode(
            // - convert the attestation object to bytes
            [UInt8](attestationObject), options: CBOROptions(maximumDepth: 16)
        )
    else {
        print("Failed to decode CBOR data")
        return nil
    }

    guard let authDataFromMap = cbor["authData"],
        case .byteString(let authData) = authDataFromMap
    else {
        print("Failed to extract authData from attestation object")
        return nil
    }

    // Parse authenticator data
    guard authData.count >= 37 else {
        print("Authenticator data too short")
        return nil
    }

    // - flags start after the RP ID hash (the first 32 bytes)
    let flags = authData[32]
    guard (flags & 0x40) != 0 else {
        print("No attested credential data present")
        return nil
    }

    // - skip the RP ID hash & flags (5 bytes)
    var index = 37

    // skip reading AAGUID (16 bytes)
    index += 16

    guard authData.count >= index + 2 else {
        print("No credential ID found")
        return nil
    }
    let credentialIdLength = UInt16(authData[index]) << 8 | UInt16(authData[index + 1])

    // skip reading credentialIdLength (2 bytes)
    index += 2

    // skip reading credentialId (variable length measured above)
    index += Int(credentialIdLength)

    // - extract the COSE key bytes from the authData
    let publicKeyBytes = Array(authData[index...])

    guard let coseKey = try? CBOR.decode(publicKeyBytes) else {
        print("Failed to decode COSE key")
        return nil
    }

    guard case .negativeInt(let curve) = coseKey[CBOR.negativeInt(0)],
        case .byteString(let xCoordinate) = coseKey[CBOR.negativeInt(1)],
        case .byteString(let yCoordinate) = coseKey[CBOR.negativeInt(2)],
        case .unsignedInt(let keyType) = coseKey[CBOR.unsignedInt(1)]
    else {
        print("Failed to extract key components")
        return nil
    }

    guard keyType == 2 else {
        print("ReactNativePasskeys Currently only supports EC2 public keys")
        return nil
    }

    let publicKeyData = Data(xCoordinate + yCoordinate)

    return publicKeyData
}
