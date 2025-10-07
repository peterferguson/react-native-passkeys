declare module "@hexagon/base64" {
	export { base64 as default };
	export namespace base64 {
		function toArrayBuffer(data: string, urlMode?: boolean): ArrayBuffer;
		function fromArrayBuffer(arrBuf: ArrayBuffer, urlMode?: boolean): string;
		// biome-ignore lint/suspicious/noShadowRestrictedNames: is in a namespace
		function toString(str: string, urlMode?: boolean): string;
		function fromString(str: string, urlMode?: boolean): string;
		function validate(encoded: string, urlMode?: boolean): boolean;
	}
}
