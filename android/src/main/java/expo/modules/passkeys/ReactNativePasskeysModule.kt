package expo.modules.passkeys

import AuthenticationResponseJSON
import PublicKeyCredentialCreationOptions
import PublicKeyCredentialRequestOptions
import RegistrationResponseJSON
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import com.google.gson.Gson
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ReactNativePasskeysModule : Module() {

    private val mainScope = CoroutineScope(Dispatchers.Default)

    override fun definition() = ModuleDefinition {
        Name("ReactNativePasskeys")

        Function("isSupported") {
            val minApiLevelPasskeys = 28
            val currentApiLevel = android.os.Build.VERSION.SDK_INT
            return@Function currentApiLevel >= minApiLevelPasskeys
        }

        Function("isAutoFillAvailable") {
            false
        }

        AsyncFunction("create") { request: PublicKeyCredentialCreationOptions, promise: Promise ->
            val credentialManager = CredentialManager.create(appContext.reactContext?.applicationContext!!)
            val json = Gson().toJson(request)
            val createPublicKeyCredentialRequest = CreatePublicKeyCredentialRequest(json)

            mainScope.launch {
                try {
                    val result = appContext.currentActivity?.let {
                        credentialManager.createCredential(it, createPublicKeyCredentialRequest)
                    }
                    val response =
                        result?.data?.getString("androidx.credentials.BUNDLE_KEY_REGISTRATION_RESPONSE_JSON")
                    val createCredentialResponse = Gson().fromJson(response, RegistrationResponseJSON::class.java)
                    promise.resolve(createCredentialResponse)
                } catch (e: expo.modules.kotlin.exception.CodedException) {
                    promise.reject(e)
                }
            }
        }

        AsyncFunction("get") { request: PublicKeyCredentialRequestOptions, promise: Promise ->
            val credentialManager = CredentialManager.create(appContext.reactContext?.applicationContext!!)
            val json = Gson().toJson(request)
            val getCredentialRequest = GetCredentialRequest(listOf(GetPublicKeyCredentialOption(json)))

            mainScope.launch {
                try {
                    val result = appContext.currentActivity?.let {
                            credentialManager.getCredential(it, getCredentialRequest)
                    }
                    val response =
                        result?.credential?.data?.getString("androidx.credentials.BUNDLE_KEY_AUTHENTICATION_RESPONSE_JSON")
                    val createCredentialResponse = Gson().fromJson(response, AuthenticationResponseJSON::class.java)
                    promise.resolve(createCredentialResponse)
                } catch (e: expo.modules.kotlin.exception.CodedException) {
                    promise.reject(e)
                }
            }
        }
    }
}
