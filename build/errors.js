export class PasskeyError extends Error {
    name;
    message;
    cause;
    constructor({ name, message, cause }) {
        super();
        this.name = name;
        this.message = message;
        this.cause = cause;
    }
}
export class UnknownError extends PasskeyError {
}
export class NotSupportedError extends PasskeyError {
    constructor(message = "Passkey are not supported") {
        super({ name: "NotSupportedError", message });
    }
}
//# sourceMappingURL=errors.js.map