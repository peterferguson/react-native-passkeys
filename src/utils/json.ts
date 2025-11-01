// This file replicates Chromium's C++ implementation of the WebAuthn API for JSON conversion.
// https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/renderer/modules/credentialmanagement/json.cc;l=320;drc=a24ab0d52080d0e89c4ef595c1187f64cff72684;bpv=0;bpt=1

import type {
  Base64URLString,
  PublicKeyCredentialUserEntity,
  PublicKeyCredentialUserEntityJSON,
  PublicKeyCredentialDescriptor,
  PublicKeyCredentialDescriptorJSON,
  PublicKeyCredentialCreationOptions,
  PublicKeyCredentialRequestOptions,
} from '../ReactNativePasskeys.types';
import type {
  PublicKeyCredentialCreationOptionsJSON,
  PublicKeyCredentialRequestOptionsJSON,
  AuthenticationExtensionsClientInputs,
  AuthenticationExtensionsClientOutputs,
  AuthenticationExtensionsClientOutputsJSON,
  AuthenticationExtensionsPRFValuesJSON,
  AuthenticationExtensionsLargeBlobInputs,
  AuthenticationExtensionsPRFInputs,
} from '../ReactNativePasskeys.types';
import { base64URLStringToBuffer, bufferToBase64URLString } from './base64';

/**
 * Error class for JSON conversion errors
 */
export class WebAuthnJSONError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'WebAuthnJSONError';
  }
}

/**
 * Encodes an ArrayBuffer to base64url string (without padding).
 */
export function webAuthnBase64UrlEncode(buffer: ArrayBuffer): Base64URLString {
  return bufferToBase64URLString(buffer);
}

/**
 * Decodes a base64url string to ArrayBuffer.
 * @returns ArrayBuffer or null if decoding fails
 */
export function webAuthnBase64UrlDecode(input: Base64URLString): ArrayBuffer | null {
  try {
    return base64URLStringToBuffer(input);
  } catch {
    return null;
  }
}

/**
 * Converts PublicKeyCredentialUserEntityJSON to PublicKeyCredentialUserEntity.
 */
export function publicKeyCredentialUserEntityFromJSON(
  json: PublicKeyCredentialUserEntityJSON
): PublicKeyCredentialUserEntity {
  const id = webAuthnBase64UrlDecode(json.id);
  if (!id) {
    throw new WebAuthnJSONError("'user.id' contains invalid base64url data");
  }

  return {
    id,
    name: json.name,
    displayName: json.displayName,
  };
}

/**
 * Converts PublicKeyCredentialDescriptorJSON to PublicKeyCredentialDescriptor.
 */
export function publicKeyCredentialDescriptorFromJSON(
  fieldName: string,
  json: PublicKeyCredentialDescriptorJSON
): PublicKeyCredentialDescriptor {
  const id = webAuthnBase64UrlDecode(json.id);
  if (!id) {
    throw new WebAuthnJSONError(
      `'${fieldName}' contains PublicKeyCredentialDescriptorJSON with invalid base64url data in 'id'`
    );
  }

  const descriptor: PublicKeyCredentialDescriptor = {
    id,
    type: json.type,
  };

  if (json.transports) {
    // @ts-expect-error - known mismatch between AuthenticatorTransportFuture & AuthenticatorTransport types
    descriptor.transports = [...json.transports];
  }

  return descriptor;
}

/**
 * Converts array of PublicKeyCredentialDescriptorJSON to array of PublicKeyCredentialDescriptor.
 */
export function publicKeyCredentialDescriptorVectorFromJSON(
  fieldName: string,
  jsonArray: PublicKeyCredentialDescriptorJSON[]
): PublicKeyCredentialDescriptor[] {
  return jsonArray.map((jsonDescriptor) =>
    publicKeyCredentialDescriptorFromJSON(fieldName, jsonDescriptor)
  );
}

/**
 * Converts AuthenticationExtensionsPRFValuesJSON to internal PRF values with ArrayBuffers.
 */
export function authenticationExtensionsPRFValuesFromJSON(
  json: AuthenticationExtensionsPRFValuesJSON
): { first: ArrayBuffer; second?: ArrayBuffer } | null {
  const first = webAuthnBase64UrlDecode(json.first);
  if (!first) 
    return null;

  const values: { first: ArrayBuffer; second?: ArrayBuffer } = { first };

  if (json.second) {
    const second = webAuthnBase64UrlDecode(json.second);
    if (!second) return null;

    values.second = second;
  }

  return values;
}

/**
 * Converts AuthenticationExtensionsClientInputs from JSON format (with base64url strings)
 * to internal format (with ArrayBuffers where appropriate).
 */
export function authenticationExtensionsClientInputsFromJSON(
  json: AuthenticationExtensionsClientInputs
): AuthenticationExtensionsClientInputs {
  const result: AuthenticationExtensionsClientInputs = {};

  if (json.appid !== undefined) {
    result.appid = json.appid;
  }
  // TODO: add support for appidExclude when supported on native platforms
  // if (json.appidExclude !== undefined) {
  //   result.appidExclude = json.appidExclude;
  // }
  if (json.hmacCreateSecret !== undefined) {
    result.hmacCreateSecret = json.hmacCreateSecret;
  }
  // TODO: add support for credentialProtectionPolicy and enforceCredentialProtectionPolicy when supported on native platforms
  // if (json.credentialProtectionPolicy !== undefined) {
  //   result.credentialProtectionPolicy = json.credentialProtectionPolicy;
  // }
  // if (json.enforceCredentialProtectionPolicy !== undefined) {
  //   result.enforceCredentialProtectionPolicy = json.enforceCredentialProtectionPolicy;
  // }
  // TODO: add support for minPinLength when supported on native platforms
  // if (json.minPinLength !== undefined) {
  //   result.minPinLength = json.minPinLength;
  // }
  if (json.credProps !== undefined) {
    result.credProps = json.credProps;
  }

  // Handle largeBlob extension
  if (json.largeBlob) {
    const largeBlob: AuthenticationExtensionsLargeBlobInputs = {};
    if (json.largeBlob.support !== undefined) {
      largeBlob.support = json.largeBlob.support;
    }
    if (json.largeBlob.read !== undefined) {
      largeBlob.read = json.largeBlob.read;
    }
    if (json.largeBlob.write !== undefined) {
      largeBlob.write = json.largeBlob.write;
    }
    result.largeBlob = largeBlob;
  }

  // Handle PRF extension
  if (json.prf) {
    const prf: AuthenticationExtensionsPRFInputs = {};

    if (json.prf.eval) {
      const evalValues = authenticationExtensionsPRFValuesFromJSON(json.prf.eval);
      if (!evalValues) {
        throw new WebAuthnJSONError("'extensions.prf.eval' contains invalid base64url data");
      }
      prf.eval = json.prf.eval; // Keep as JSON format for inputs
    }

    if (json.prf.evalByCredential) {
      const evalByCredential: Record<Base64URLString, { first: Base64URLString; second?: Base64URLString }> = {};
      for (const [key, jsonValues] of Object.entries(json.prf.evalByCredential)) {
        // Validate the values can be decoded
        const values = authenticationExtensionsPRFValuesFromJSON(jsonValues);
        if (!values) {
          throw new WebAuthnJSONError(
            "'extensions.prf.evalByCredential' contains invalid base64url data"
          );
        }
        evalByCredential[key] = jsonValues; // Keep as JSON format for inputs
      }
      prf.evalByCredential = evalByCredential;
    }

    result.prf = prf;
  }

  return result;
}

/**
 * Converts AuthenticationExtensionsClientOutputs to JSON format.
 */
export function authenticationExtensionsClientOutputsToJSON(
  outputs: AuthenticationExtensionsClientOutputs
): AuthenticationExtensionsClientOutputsJSON {
  const json: AuthenticationExtensionsClientOutputsJSON = {};

  // TODO: add support for appid and hmacCreateSecret when supported on native platforms
  // if (outputs.appid !== undefined) {
  //   json.appid = outputs.appid;
  // }
  // if (outputs.hmacCreateSecret !== undefined) {
  //   json.hmacCreateSecret = outputs.hmacCreateSecret;
  // }
  if (outputs.credProps !== undefined) {
    json.credProps = outputs.credProps;
  }

  // Handle largeBlob extension
  if (outputs.largeBlob) {
    const largeBlob: AuthenticationExtensionsClientOutputsJSON['largeBlob'] = {};
    if (outputs.largeBlob.supported !== undefined) {
      largeBlob.supported = outputs.largeBlob.supported;
    }
    if (outputs.largeBlob.blob !== undefined) {
      largeBlob.blob = webAuthnBase64UrlEncode(outputs.largeBlob.blob);
    }
    if (outputs.largeBlob.written !== undefined) {
      largeBlob.written = outputs.largeBlob.written;
    }
    json.largeBlob = largeBlob;
  }

  // Handle PRF extension
  if (outputs.prf) {
    const prf: AuthenticationExtensionsClientOutputsJSON['prf'] = {};
    if (outputs.prf.enabled !== undefined) {
      prf.enabled = outputs.prf.enabled;
    }
    if (outputs.prf.results) {
      prf.results = {
        first: webAuthnBase64UrlEncode(outputs.prf.results.first),
      };
      if (outputs.prf.results.second !== undefined) {
        prf.results.second = webAuthnBase64UrlEncode(outputs.prf.results.second);
      }
    }
    json.prf = prf;
  }

  return json;
}

/**
 * Converts PublicKeyCredentialCreationOptionsJSON to PublicKeyCredentialCreationOptions.
 */
export function publicKeyCredentialCreationOptionsFromJSON(
  json: PublicKeyCredentialCreationOptionsJSON
): PublicKeyCredentialCreationOptions {
  const challenge = webAuthnBase64UrlDecode(json.challenge);
  if (!challenge) {
    throw new WebAuthnJSONError("'challenge' contains invalid base64url data");
  }

  const user = publicKeyCredentialUserEntityFromJSON(json.user);

  const result: PublicKeyCredentialCreationOptions = {
    rp: json.rp,
    user,
    challenge,
    pubKeyCredParams: json.pubKeyCredParams,
  };

  if (json.timeout !== undefined) {
    result.timeout = json.timeout;
  }

  if (json.excludeCredentials) {
    result.excludeCredentials = publicKeyCredentialDescriptorVectorFromJSON(
      'excludeCredentials',
      json.excludeCredentials
    );
  }

  if (json.authenticatorSelection) {
    result.authenticatorSelection = json.authenticatorSelection;
  }

  if (json.attestation !== undefined) {
    result.attestation = json.attestation;
  }

  if (json.extensions) {
    result.extensions = authenticationExtensionsClientInputsFromJSON(json.extensions);
  }

  return result;
}

/**
 * Converts PublicKeyCredentialRequestOptionsJSON to PublicKeyCredentialRequestOptions.
 */
export function publicKeyCredentialRequestOptionsFromJSON(
  json: PublicKeyCredentialRequestOptionsJSON
): PublicKeyCredentialRequestOptions {
  const challenge = webAuthnBase64UrlDecode(json.challenge);
  if (!challenge) {
    throw new WebAuthnJSONError("'challenge' contains invalid base64url data");
  }

  const result: PublicKeyCredentialRequestOptions = {
    challenge,
  };

  if (json.timeout !== undefined) {
    result.timeout = json.timeout;
  }

  if (json.rpId !== undefined) {
    result.rpId = json.rpId;
  }

  if (json.allowCredentials) {
    result.allowCredentials = publicKeyCredentialDescriptorVectorFromJSON(
      'allowCredentials',
      json.allowCredentials
    );
  }

  if (json.userVerification !== undefined) {
    result.userVerification = json.userVerification;
  }

  if (json.extensions) {
    result.extensions = authenticationExtensionsClientInputsFromJSON(json.extensions);
  }

  return result;
}
