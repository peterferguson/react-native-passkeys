import type {
	// - for override
	AuthenticationExtensionsClientInputs as TypeScriptAuthenticationExtensionsClientInputs,
	// - for use & reexport
	Base64URLString,
	AuthenticatorTransportFuture,
	PublicKeyCredentialJSON,
	PublicKeyCredentialDescriptorJSON,
	PublicKeyCredentialUserEntityJSON,
	AuthenticatorAttestationResponseJSON,
} from '@simplewebauthn/typescript-types'

export type {
	AttestationConveyancePreference,
	AuthenticationCredential,
	AuthenticatorAssertionResponse,
	AuthenticatorAttachment,
	AuthenticatorAttestationResponse,
	AuthenticatorSelectionCriteria,
	AuthenticatorTransport,
	COSEAlgorithmIdentifier,
	Crypto,
	PublicKeyCredentialCreationOptions,
	PublicKeyCredentialDescriptor,
	PublicKeyCredentialParameters,
	PublicKeyCredentialRequestOptions,
	PublicKeyCredentialRpEntity,
	PublicKeyCredentialType,
	PublicKeyCredentialUserEntity,
	RegistrationCredential,
	UserVerificationRequirement,
} from '@simplewebauthn/typescript-types'

export type {
	Base64URLString,
	PublicKeyCredentialJSON,
	AuthenticatorTransportFuture,
	PublicKeyCredentialDescriptorJSON,
	PublicKeyCredentialUserEntityJSON,
	AuthenticatorAttestationResponseJSON,
}

/**
 * A variant of PublicKeyCredentialCreationOptions suitable for JSON transmission
 *
 * This should eventually get replaced with official TypeScript DOM types when WebAuthn L3 types
 * eventually make it into the language:
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-publickeycredentialcreationoptionsjson
 */
export interface PublicKeyCredentialCreationOptionsJSON {
	rp: PublicKeyCredentialRpEntity
	user: PublicKeyCredentialUserEntityJSON
	challenge: Base64URLString
	pubKeyCredParams: PublicKeyCredentialParameters[]
	timeout?: number
	excludeCredentials?: PublicKeyCredentialDescriptorJSON[]
	authenticatorSelection?: AuthenticatorSelectionCriteria
	attestation?: AttestationConveyancePreference
	extensions?: AuthenticationExtensionsClientInputs
}

/**
 * A variant of PublicKeyCredentialRequestOptions suitable for JSON transmission
 */
export interface PublicKeyCredentialRequestOptionsJSON {
	challenge: Base64URLString
	timeout?: number
	rpId?: string
	allowCredentials?: PublicKeyCredentialDescriptorJSON[]
	userVerification?: UserVerificationRequirement
	extensions?: AuthenticationExtensionsClientInputs
}

/**
 * A slightly-modified RegistrationCredential to simplify working with ArrayBuffers that
 * are Base64URL-encoded so that they can be sent as JSON.
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-registrationresponsejson
 */
export interface RegistrationResponseJSON {
	id: Base64URLString
	rawId: Base64URLString
	response: AuthenticatorAttestationResponseJSON
	authenticatorAttachment?: AuthenticatorAttachment
	clientExtensionResults: AuthenticationExtensionsClientOutputs
	type: PublicKeyCredentialType
}

/**
 * A slightly-modified AuthenticationCredential to simplify working with ArrayBuffers that
 * are Base64URL-encoded so that they can be sent as JSON.
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationresponsejson
 */
export interface AuthenticationResponseJSON {
	id: Base64URLString
	rawId: Base64URLString
	response: AuthenticatorAssertionResponseJSON
	authenticatorAttachment?: AuthenticatorAttachment
	clientExtensionResults: AuthenticationExtensionsClientOutputs
	type: PublicKeyCredentialType
}

/**
 * A slightly-modified AuthenticatorAssertionResponse to simplify working with ArrayBuffers that
 * are Base64URL-encoded so that they can be sent as JSON.
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticatorassertionresponsejson
 */
export interface AuthenticatorAssertionResponseJSON {
	clientDataJSON: Base64URLString
	authenticatorData: Base64URLString
	signature: Base64URLString
	userHandle?: string
}

/**
 * TypeScript's types are behind the latest extensions spec, so we define them here.
 * Should eventually be replaced by TypeScript's when TypeScript gets updated to
 * know about it (sometime after 5.3)
 *
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionsclientinputs
 */
export interface AuthenticationExtensionsClientInputs
	extends TypeScriptAuthenticationExtensionsClientInputs {
	largeBlob?: AuthenticationExtensionsLargeBlobInputs
}

export type LargeBlobSupport = 'preferred' | 'required'

/**
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargeblobinputs
 */
export interface AuthenticationExtensionsLargeBlobInputs {
	// - Only valid during registration.
	support?: LargeBlobSupport

	// - A boolean that indicates that the Relying Party would like to fetch the previously-written blob associated with the asserted credential. Only valid during authentication.
	read?: boolean

	// - An opaque byte string that the Relying Party wishes to store with the existing credential. Only valid during authentication.
	// - We impose that the data is passed as base64-url encoding to make better align the passing of data from RN to native code
	write?: Base64URLString
}

// - largeBlob extension: https://w3c.github.io/webauthn/#sctn-large-blob-extension
export interface AuthenticationExtensionsClientOutputs {
	largeBlob?: AuthenticationExtensionsLargeBlobOutputs
}

/**
 * - Specification reference: https://w3c.github.io/webauthn/#dictdef-authenticationextensionslargebloboutputs
 */
export interface AuthenticationExtensionsLargeBlobOutputs {
	// - true if, and only if, the created credential supports storing large blobs. Only present in registration outputs.
	supported?: boolean

	// - The opaque byte string that was associated with the credential identified by rawId. Only valid if read was true.
	blob?: Base64URLString

	// - A boolean that indicates that the contents of write were successfully stored on the authenticator, associated with the specified credential.
	written?: boolean
}
