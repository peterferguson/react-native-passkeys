import { Linking, Platform, Pressable, ScrollView, StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import * as Application from "expo-application";
import * as passkey from "react-native-passkeys";
import alert from "../utils/alert";
import React from "react";
import { base64 } from "@hexagon/base64";
import type {
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
	return new TextEncoder().encode(value).buffer;
}

/**
 * Decode a base64url string into its original string
 */
export function base64UrlToString(base64urlString: Base64URLString): string {
	return base64.toString(base64urlString, true);
}

const bundleId = Application.applicationId?.split(".").reverse().join(".");

// the example app is running on the web.app domain but the bundleId is com.web.react-native-passkeys
// so we need to replace the last part of the bundleId with the domain
const hostname = bundleId?.replaceAll("web.com", "web.app")?.replaceAll("_", "-");

const rp = {
	id: Platform.select({
		web: undefined,
		ios: hostname,
		android: hostname,
	}),
	name: "ReactNativePasskeys",
} satisfies PublicKeyCredentialRpEntity;

// Don't do this in production!
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

type CreationResponse = NonNullable<Awaited<ReturnType<typeof passkey.create>>>;
type GetResponse = NonNullable<Awaited<ReturnType<typeof passkey.get>>>;
type Result = CreationResponse | GetResponse | null;

export default function App() {
	const insets = useSafeAreaInsets();

	const [result, setResult] = React.useState<Result>(null);
	const [creationResponse, setCreationResponse] = React.useState<
		CreationResponse["response"] | null
	>(null);
	const [credentialId, setCredentialId] = React.useState("");

	const createPasskey = async () => {
		try {
			const json = await passkey.create({
				challenge,
				pubKeyCredParams: [{ alg: -7, type: "public-key" }],
				rp,
				user,
				authenticatorSelection,
				extensions: {
					...(Platform.OS !== "android" && { largeBlob: { support: "required" } }),
					prf: {},
				},
			});

			console.log("creation json -", json);

			if (json?.rawId) setCredentialId(json.rawId);
			if (json?.response) setCreationResponse(json.response);

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
				largeBlob: { write: bufferToBase64URLString(utf8StringToBuffer("Hey its a private key!")) },
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

	const deriveKey = async () => {
		const json = await passkey.get({
			rpId: rp.id,
			challenge,
			extensions: {
				prf: { eval: { first: bufferToBase64URLString(utf8StringToBuffer("my derived key")) } },
			},
			...(credentialId && {
				allowCredentials: [{ id: credentialId, type: "public-key" }],
			}),
		});

		console.log("derive key json -", json);

		setResult(json);
	};

	return (
		<View style={{ flex: 1 }}>
			<ScrollView
				style={{
					flex: 1,
					backgroundColor: "#fccefe",
				}}
				contentContainerStyle={[
					styles.scrollContainer,
					{ paddingTop: insets.top, paddingBottom: insets.bottom + 60 },
				]}
			>
				<Text style={styles.title}>Testing Passkeys</Text>
				<Text>Application ID: {Application.applicationId}</Text>
				<Text>Passkeys are {passkey.isSupported() ? "supported" : "not supported"}</Text>
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
					<Pressable style={styles.button} onPress={deriveKey}>
						<Text>Derive Key (PRF)</Text>
					</Pressable>
					{creationResponse && (
						<Pressable
							style={styles.button}
							onPress={() => {
								const publicKey = creationResponse.getPublicKey();
								if (!publicKey) alert("No public key found");
								else alert("Public Key", publicKey);
							}}
						>
							<Text>Get PublicKey</Text>
						</Pressable>
					)}
				</View>
				{result && <Text style={styles.resultText}>Result {JSON.stringify(result, null, 2)}</Text>}
			</ScrollView>
			<Text
				style={{
					textAlign: "center",
					position: "absolute",
					bottom: insets.bottom + 16,
					left: 0,
					right: 0,
				}}
			>
				Source available on{" "}
				<Text
					onPress={() => Linking.openURL("https://github.com/peterferguson/react-native-passkeys")}
					style={{ textDecorationLine: "underline" }}
				>
					GitHub
				</Text>
			</Text>
		</View>
	);
}

const styles = StyleSheet.create({
	scrollContainer: {
		flexGrow: 1,
		alignItems: "center",
		justifyContent: "center",
	},
	title: {
		fontSize: 20,
		fontWeight: "bold",
		marginVertical: "5%",
	},
	resultText: {
		maxWidth: "80%",
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
