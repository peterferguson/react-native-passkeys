// Import the native module. On web, it will be resolved to ReactNativePasskeys.web.ts
// and on native platforms to ReactNativePasskeys.ts
import ReactNativePasskeysModule from "./ReactNativePasskeysModule";
export function isSupported() {
    return ReactNativePasskeysModule.isSupported();
}
export function isAutoFillAvalilable() {
    return ReactNativePasskeysModule.isAutoFillAvalilable();
}
export async function create(request, options) {
    return await ReactNativePasskeysModule.create(request, options?.ios?.requireBiometrics ?? false);
}
export async function get(request, options) {
    return await ReactNativePasskeysModule.get(request, options?.ios?.requireBiometrics ?? false);
}
//# sourceMappingURL=index.js.map