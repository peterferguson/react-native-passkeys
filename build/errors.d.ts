export declare class PasskeyError<T extends string> extends Error {
    name: T;
    message: string;
    cause?: unknown;
    constructor({ name, message, cause }: {
        name: T;
        message: string;
        cause?: unknown;
    });
}
export declare class UnknownError extends PasskeyError<"UnknownError"> {
}
export declare class NotSupportedError extends PasskeyError<"NotSupportedError"> {
    constructor(message?: string);
}
//# sourceMappingURL=errors.d.ts.map