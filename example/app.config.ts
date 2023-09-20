import type { ExpoConfig } from "@expo/config-types";

const hostname = process.env.EXPO_PUBLIC_HOSTNAME;
if (!hostname) throw new Error("HOSTNAME environment variable must be set");
const scheme = "passkeyexample";
const bundleIdentifier = `${hostname.split(".").reverse().join(".")}.${scheme}`;

const config = {
	name: "expo-passkeys-example",
	slug: "expo-passkeys-example",
	owner: "Peter Ferguson",
	version: "1.0.0",
	orientation: "portrait",
	scheme,
	icon: "./assets/icon.png",
	userInterfaceStyle: "light",
	splash: {
		image: "./assets/splash.png",
		resizeMode: "contain",
		backgroundColor: "#ffffff",
	},
	assetBundlePatterns: ["**/*"],
	ios: {
		supportsTablet: true,
		bundleIdentifier,
		associatedDomains: [`applinks:${scheme}.${hostname}`, `webcredentials:${scheme}.${hostname}`],
		infoPlist: { UIBackgroundModes: ["fetch", "remote-notification"] },
	},
	android: {
		adaptiveIcon: {
			foregroundImage: "./assets/adaptive-icon.png",
			backgroundColor: "#ffffff",
		},
		package: bundleIdentifier,
	},
	web: {
		bundler: "metro",
		favicon: "./assets/favicon.png",
	},
	plugins: ["expo-router", ["expo-build-properties", { ios: { deploymentTarget: "15.0" } }]],
} satisfies ExpoConfig;

export default config;
