import { Platform, Pressable, StyleSheet, Text, View } from "react-native";

import * as Application from "expo-application";
import * as passkey from "react-native-passkeys";
import alert from "../utils/alert";
import React from "react";
import base64 from "@hexagon/base64";
import {
	Base64URLString,
	PublicKeyCredentialUserEntityJSON,
} from "@simplewebauthn/typescript-types";

// ! taken from https://github.com/MasterKale/SimpleWebAuthn/blob/e02dce6f2f83d8923f3a549f84e0b7b3d44fa3da/packages/browser/src/helpers/bufferToBase64URLString.ts
/**
 * Convert the given array buffer into a Base64URL-encoded string. Ideal for converting various
 * credential response ArrayBuffers to string for sending back to the server as JSON.
 *
 * Helper method to compliment `base64URLStringToBuffer`
 */
export function bufferToBase64URLString(buffer: ArrayBuffer): string {
	const bytes = new Uint8Array(buffer);
	let str = "";

	for (const charCode of bytes) {
		str += String.fromCharCode(charCode);
	}

	const base64String = btoa(str);

	return base64String.replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}

// ! taken from https://github.com/MasterKale/SimpleWebAuthn/blob/e02dce6f2f83d8923f3a549f84e0b7b3d44fa3da/packages/browser/src/helpers/utf8StringToBuffer.ts
/**
 * A helper method to convert an arbitrary string sent from the server to an ArrayBuffer the
 * authenticator will expect.
 */
export function utf8StringToBuffer(value: string): ArrayBuffer {
	return new TextEncoder().encode(value);
}

/**
 * Decode a base64url string into its original string
 */
export function base64UrlToString(base64urlString: Base64URLString): string {
	return base64.toString(base64urlString, true);
}

const rp = {
	id: Platform.select({
		web: undefined,
		native: `${Application.applicationId?.split(".").reverse().join(".")}`,
	}),
	name: "ReactNativePasskeys",
} satisfies PublicKeyCredentialRpEntity;

const challenge = bufferToBase64URLString(utf8StringToBuffer("fizz"));

const user = {
	id: bufferToBase64URLString(utf8StringToBuffer("290283490")),
	displayName: "username",
	name: "username",
} satisfies PublicKeyCredentialUserEntityJSON;

const authenticatorSelection = {
	userVerification: "required",
	residentKey: "required",
} satisfies AuthenticatorSelectionCriteria;

export default function App() {
	const [result, setResult] = React.useState();
	const [credentialId, setCredentialId] = React.useState("");

	const createPasskey = async () => {
		try {
			const json = await passkey.create({
				challenge,
				pubKeyCredParams: [{ alg: -7, type: "public-key" }],
				rp,
				user,
				authenticatorSelection,
				extensions: { largeBlob: { support: "required" } },
			});

			console.log("creation json -", json);

			if (json?.rawId) setCredentialId(json.rawId);

			setResult(json);
		} catch (e) {
			console.error("create error", e);
		}
	};

	const authenticatePasskey = async () => {
		const json = await passkey.get({
			rpId: rp.id,
			challenge,
			...(credentialId && {
				allowCredentials: [{ id: credentialId, type: "public-key" }],
			}),
		});

		console.log("authentication json -", json);

		setResult(json);
	};

	const writeBlob = async () => {
		console.log("user credential id -", credentialId);
		if (!credentialId) {
			alert("No user credential id found - large blob requires a selected credential");
			return;
		}

		const json = await passkey.get({
			rpId: rp.id,
			challenge,
			extensions: {
				largeBlob: { write: bufferToBase64URLString(utf8StringToBuffer("my first large blob")) },
			},
			...(credentialId && {
				allowCredentials: [{ id: credentialId, type: "public-key" }],
			}),
		});

		console.log("add blob json -", json);

		const written = json?.clientExtensionResults?.largeBlob?.written;
		if (written) alert("This blob was written to the passkey");

		setResult(json);
	};

	const readBlob = async () => {
		const json = await passkey.get({
			rpId: rp.id,
			challenge,
			extensions: { largeBlob: { read: true } },
			...(credentialId && {
				allowCredentials: [{ id: credentialId, type: "public-key" }],
			}),
		});

		console.log("read blob json -", json);

		const blob = json?.clientExtensionResults?.largeBlob?.blob;
		if (blob) alert("This passkey has blob", base64UrlToString(blob));

		setResult(json);
	};

	return (
		<View style={styles.container}>
			<Text style={styles.title}>Testing Passkeys</Text>
			<Text>Application ID: {Application.applicationId}</Text>
			<Text>Passkeys are {passkey.isSupported() ? "Supported" : "Not Supported"}</Text>
			{credentialId && <Text>User Credential ID: {credentialId}</Text>}
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
			{result && <Text style={styles.resultText}>Result {JSON.stringify(result, null, 2)}</Text>}
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: "#fccefe",
		alignItems: "center",
		justifyContent: "center",
	},
	title: {
		fontSize: 20,
		fontWeight: "bold",
		marginVertical: "5%",
	},
	resultText: {
		maxWidth: "60%",
	},
	buttonContainer: {
		padding: 24,
		flexDirection: "row",
		flexWrap: "wrap",
		alignItems: "center",
		rowGap: 4,
		justifyContent: "space-evenly",
	},
	button: {
		backgroundColor: "#fff",
		padding: 10,
		borderWidth: 1,
		borderRadius: 5,
		width: "45%",
		alignItems: "center",
		justifyContent: "center",
		textAlign: "center",
	},
});
