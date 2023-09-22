import { Pressable, StyleSheet, Text, View } from 'react-native'

import * as Application from 'expo-application'
import * as passkey from 'expo-passkeys'
import { useEffect } from 'react'

// ! taken from https://github.com/MasterKale/SimpleWebAuthn/blob/e02dce6f2f83d8923f3a549f84e0b7b3d44fa3da/packages/browser/src/helpers/bufferToBase64URLString.ts
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

// ! taken from https://github.com/MasterKale/SimpleWebAuthn/blob/e02dce6f2f83d8923f3a549f84e0b7b3d44fa3da/packages/browser/src/helpers/utf8StringToBuffer.ts
/**
 * A helper method to convert an arbitrary string sent from the server to an ArrayBuffer the
 * authenticator will expect.
 */
export function utf8StringToBuffer(value: string): ArrayBuffer {
	return new TextEncoder().encode(value)
}

export default function App() {
	const createPasskey = async () => {
		try {
			await passkey.create({
				challenge: bufferToBase64URLString(utf8StringToBuffer('fizz')),
				pubKeyCredParams: [{ alg: -7, type: 'public-key' }],
				rp: {
					id: `${Application.applicationId?.split('.').reverse().join('.')}`,
					name: 'ExpoPasskeys',
				},
				user: {
					id: bufferToBase64URLString(utf8StringToBuffer('290283490')),
					displayName: 'username',
					name: 'username',
				},
			})
		} catch (e) {
			console.error('create error', e)
		}
	}

	const authenticatePasskey = async () => {
		await passkey.get({
			rpId: `${Application.applicationId?.split('.').reverse().join('.')}`,
			challenge: bufferToBase64URLString(utf8StringToBuffer('fizz')),
			// allowCredentials: [{ id: "5678", type: "public-key" }],
		})
	}

	return (
		<View style={styles.container}>
			<Text style={styles.title}>Testing Passkeys</Text>
			<Text>Application ID: {Application.applicationId}</Text>
			<Text>Passkeys are {passkey.isSupported() ? 'Supported' : 'Not Supported'}</Text>
			<View style={styles.buttonContainer}>
				<Pressable style={styles.button} onPress={createPasskey}>
					<Text>Create Passkey</Text>
				</Pressable>
				<Pressable style={styles.button} onPress={authenticatePasskey}>
					<Text>Authenticate Passkey</Text>
				</Pressable>
			</View>
		</View>
	)
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: '#fccefe',
		alignItems: 'center',
		justifyContent: 'center',
	},
	title: {
		fontSize: 20,
		fontWeight: 'bold',
		marginVertical: '5%',
	},
	buttonContainer: {
		width: '60%',
		padding: 10,
		flexDirection: 'row',
		justifyContent: 'space-between',
	},
	button: {
		backgroundColor: '#fff',
		padding: 10,
		margin: 10,
		borderRadius: 5,
		width: '45%',
		alignItems: 'center',
		justifyContent: 'center',
		textAlign: 'center',
	},
})
