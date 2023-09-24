// ! taken from https://github.com/MasterKale/SimpleWebAuthn/blob/e02dce6f2f83d8923f3a549f84e0b7b3d44fa3da/packages/browser/src/helpers/base64URLStringToBuffer.ts
/**
 * Convert from a Base64URL-encoded string to an Array Buffer. Best used when converting a
 * credential ID from a JSON string to an ArrayBuffer, like in allowCredentials or
 * excludeCredentials
 *
 * Helper method to compliment `bufferToBase64URLString`
 */
export function base64URLStringToBuffer(base64URLString: string): ArrayBuffer {
	// Convert from Base64URL to Base64
	const base64 = base64URLString.replace(/-/g, '+').replace(/_/g, '/')
	/**
	 * Pad with '=' until it's a multiple of four
	 * (4 - (85 % 4 = 1) = 3) % 4 = 3 padding
	 * (4 - (86 % 4 = 2) = 2) % 4 = 2 padding
	 * (4 - (87 % 4 = 3) = 1) % 4 = 1 padding
	 * (4 - (88 % 4 = 0) = 4) % 4 = 0 padding
	 */
	const padLength = (4 - (base64.length % 4)) % 4
	const padded = base64.padEnd(base64.length + padLength, '=')

	// Convert to a binary string
	const binary = atob(padded)

	// Convert binary string to buffer
	const buffer = new ArrayBuffer(binary.length)
	const bytes = new Uint8Array(buffer)

	for (let i = 0; i < binary.length; i++) {
		bytes[i] = binary.charCodeAt(i)
	}

	return buffer
}

/**
 * Convert the given array buffer into a Base64URL-encoded string. Ideal for converting various
 * credential response ArrayBuffers to string for sending back to the server as JSON.
 *
 * Helper method to compliment `base64URLStringToBuffer`
 */
export function bufferToBase64URLString(buffer: ArrayBuffer): string {
	const bytes = new Uint8Array(buffer)
	let str = ''

	for (const charCode of bytes) {
		str += String.fromCharCode(charCode)
	}

	const base64String = btoa(str)

	return base64String.replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')
}
