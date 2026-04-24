const mockNativeModule = {
	isSupported: jest.fn(() => true),
	isAccountCreationSupported: jest.fn(() => true),
	createAccount: jest.fn(),
};

jest.mock("expo-modules-core", () => ({
	requireNativeModule: jest.fn(() => mockNativeModule),
}));

describe("ReactNativePasskeysModule.createAccount", () => {
	beforeEach(() => {
		jest.clearAllMocks();
		jest.resetModules();
		mockNativeModule.isSupported.mockReturnValue(true);
		mockNativeModule.isAccountCreationSupported.mockReturnValue(true);
	});

	it("wraps the native account creation response with getPublicKey", async () => {
		mockNativeModule.createAccount.mockResolvedValue({
			id: "credential-id",
			rawId: "credential-id",
			type: "public-key",
			account: {
				contactIdentifier: {
					type: "email",
					value: "andrew@example.com",
				},
			},
			response: {
				clientDataJSON: "client-data",
				attestationObject: "attestation-object",
				publicKey: "public-key",
			},
			clientExtensionResults: {},
		});

		const module = require("../ReactNativePasskeysModule").default;
		const response = await module.createAccount({
			acceptedContactIdentifiers: ["email", "phoneNumber"],
			challenge: "challenge",
			rpId: "example.com",
			shouldRequestName: true,
			userId: "user-id",
		});

		expect(mockNativeModule.createAccount).toHaveBeenCalledWith({
			acceptedContactIdentifiers: ["email", "phoneNumber"],
			challenge: "challenge",
			rpId: "example.com",
			shouldRequestName: true,
			userId: "user-id",
		});
		expect(response?.account.contactIdentifier).toEqual({
			type: "email",
			value: "andrew@example.com",
		});
		expect(response?.response.getPublicKey()).toBe("public-key");
	});

	it("throws when account creation is not supported", async () => {
		mockNativeModule.isAccountCreationSupported.mockReturnValue(false);

		const module = require("../ReactNativePasskeysModule").default;

		await expect(
			module.createAccount({
				acceptedContactIdentifiers: ["email"],
				challenge: "challenge",
				rpId: "example.com",
				userId: "user-id",
			}),
		).rejects.toMatchObject({
			name: "NotSupportedError",
		});
	});
});
