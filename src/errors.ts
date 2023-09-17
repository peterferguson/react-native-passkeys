export class PasskeyError<T extends string> extends Error {
	name: T;
	message: string;
	cause?: unknown;

	constructor({ name, message, cause }: { name: T; message: string; cause?: unknown }) {
		super();
		this.name = name;
		this.message = message;
		this.cause = cause;
	}
}

export class UnknownError extends PasskeyError<"UnknownError"> {}

export class NotSupportedError extends PasskeyError<"NotSupportedError"> {
	constructor(message = "Passkey are not supported") {
		super({ name: "NotSupportedError", message });
	}
}
