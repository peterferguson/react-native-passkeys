import Foundation

func getPublicKey(from attestationObject: Data)
    -> Data?
{
    let cborDecoded = try? SimpleCBORDecoder.decode([UInt8](attestationObject))
    guard let decodedAttestationObjectMap = cborDecoded as? [String: Any],
        let authData = decodedAttestationObjectMap["authData"] as? Data
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
    let publicKeyBytes = [UInt8](authData[index...])

    let decodedPublicKey = try? SimpleCBORDecoder.decode(publicKeyBytes)
    guard let cosePublicKey = decodedPublicKey as? [AnyHashable: Any]
    else {
        print("Failed to decode COSE key")
        return nil
    }

    guard let curve = cosePublicKey[-1] as? UInt64,
        let xCoordinate = cosePublicKey[-2] as? Data,
        let yCoordinate = cosePublicKey[-3] as? Data,
        let keyType = cosePublicKey[1] as? UInt64,
        let algorithm = cosePublicKey[3] as? Int
    else {
        print("Failed to extract key components")
        return nil
    }

    // https://www.w3.org/TR/webauthn-3/#example-bdbd14cc
    guard keyType == 2, algorithm == -7, curve == 1 else {
        print("ReactNativePasskeys currently only supports EC2 public keys")
        return nil
    }

    let publicKeyData = Data(xCoordinate + yCoordinate)

    return publicKeyData
}
