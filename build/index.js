// Import the native module. On web, it will be resolved to ReactNativePasskeys.web.ts
// and on native platforms to ReactNativePasskeys.ts
import ReactNativePasskeysModule from "./ReactNativePasskeysModule";
export function isSupported() {
    return ReactNativePasskeysModule.isSupported();
}
export function isAutoFillAvalilable() {
    return ReactNativePasskeysModule.isAutoFillAvalilable();
}
export function isAccountCreationSupported() {
    return ReactNativePasskeysModule.isAccountCreationSupported();
}
export async function create(request) {
    return await ReactNativePasskeysModule.create(request);
}
export async function get(request) {
    return await ReactNativePasskeysModule.get(request);
}
export async function createAccount(request) {
    return await ReactNativePasskeysModule.createAccount(request);
}
//# sourceMappingURL=index.js.map