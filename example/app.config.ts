import type { ExpoConfig } from "@expo/config-types";

// const hostname = process.env.EXPO_PUBLIC_HOSTNAME;
// if (!hostname) throw new Error("HOSTNAME environment variable must be set");
const hostname = "web.app";
const scheme = "react-native-passkeys";
const bundleIdentifier = `com.web.${scheme}`;

const config = {
	name: `${scheme}-example`,
	slug: `${scheme}-example`,
	owner: "peterferguson",
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
		package: bundleIdentifier.replaceAll("-", "_"),
	},
	web: {
		bundler: "metro",
		favicon: "./assets/favicon.png",
	},
	plugins: [
		"expo-router",
		[
			"expo-build-properties",
			{
				ios: { deploymentTarget: "15.1" },
				android: { compileSdkVersion: 36 },
			},
		],
	],
	extra: {
		eas: {
			projectId: "40f72999-42a4-4df5-adfe-e3926e2b937f",
		},
	},
} satisfies ExpoConfig;

export default config;
