import { Pressable, StyleSheet, Text, View } from 'react-native'

import * as Application from 'expo-application'
import * as passkey from 'react-native-passkeys'
import { Alert } from 'react-native'
import React from 'react'

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
	const [result, setResult] = React.useState()

	const createPasskey = async () => {
		try {
			const json = await passkey.create({
				challenge: bufferToBase64URLString(utf8StringToBuffer('fizz')),
				pubKeyCredParams: [{ alg: -7, type: 'public-key' }],
				rp: {
					id: `${Application.applicationId?.split('.').reverse().join('.')}`,
					name: 'ReactNativePasskeys',
				},
				user: {
					id: bufferToBase64URLString(utf8StringToBuffer('290283490')),
					displayName: 'username',
					name: 'username',
				},
				extensions: { largeBlob: { support: 'preferred' } },
			})

			console.log('creation json -', json)

			setResult(json)
		} catch (e) {
			console.error('create error', e)
		}
	}

	const authenticatePasskey = async () => {
		const json = await passkey.get({
			rpId: `${Application.applicationId?.split('.').reverse().join('.')}`,
			challenge: bufferToBase64URLString(utf8StringToBuffer('fizz')),
			// extensions: { largeBlob: { read: true } },
			// allowCredentials: [{ id: '5678', type: 'public-key' }],
		})

		console.log('authentication json -', json)

		setResult(json)
	}

	const writeBlob = async () => {
		const json = await passkey.get({
			rpId: `${Application.applicationId?.split('.').reverse().join('.')}`,
			challenge: bufferToBase64URLString(utf8StringToBuffer('fizz')),
			extensions: {
				largeBlob: { write: bufferToBase64URLString(utf8StringToBuffer('my first large blob')) },
			},
			// allowCredentials: [{ id: '5678', type: 'public-key' }],
		})

		const written = json?.clientExtensionResults.largeBlob?.written
		if (written) Alert.alert('This blob was written to the passkey')

		setResult(json)
	}
	const readBlob = async () => {
		const json = await passkey.get({
			rpId: `${Application.applicationId?.split('.').reverse().join('.')}`,
			challenge: bufferToBase64URLString(utf8StringToBuffer('fizz')),
			extensions: { largeBlob: { read: true } },
			// allowCredentials: [{ id: '5678', type: 'public-key' }],
		})

		const blob = json?.clientExtensionResults.largeBlob?.blob
		if (blob) Alert.alert('This passkey has blob', blob)

		setResult(json)
	}

	return (
		<View style={styles.container}>
			<Text style={styles.title}>Testing Passkeys</Text>
			<Text>Application ID: {Application.applicationId}</Text>
			<Text>Passkeys are {passkey.isSupported() ? 'Supported' : 'Not Supported'}</Text>
			<View style={styles.buttonContainer}>
				<Pressable style={styles.button} onPress={createPasskey}>
					<Text>Create</Text>
				</Pressable>
				<Pressable style={styles.button} onPress={authenticatePasskey}>
					<Text>Authenticate</Text>
				</Pressable>
				<Pressable style={styles.button} onPress={writeBlob}>
					<Text>Add Blob</Text>
				</Pressable>
				<Pressable style={styles.button} onPress={readBlob}>
					<Text>Read Blob</Text>
				</Pressable>
			</View>
			{result && <Text>Result {JSON.stringify(result, null, 2)}</Text>}
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
		padding: 24,
		flexDirection: 'row',
		flexWrap: 'wrap',
		alignItems: 'center',
		rowGap: 4,
		justifyContent: 'space-evenly',
	},
	button: {
		backgroundColor: '#fff',
		padding: 10,
		borderWidth: 1,
		borderRadius: 5,
		width: '45%',
		alignItems: 'center',
		justifyContent: 'center',
		textAlign: 'center',
	},
})
