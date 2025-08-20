package expo.modules.passkeys

import AuthenticationResponseJSON
import PublicKeyCredentialCreationOptions
import PublicKeyCredentialRequestOptions
import RegistrationResponseJSON
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.CreateCredentialInterruptedException
import androidx.credentials.exceptions.CreateCredentialProviderConfigurationException
import androidx.credentials.exceptions.CreateCredentialUnknownException
import androidx.credentials.exceptions.CreateCredentialUnsupportedException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.GetCredentialInterruptedException
import androidx.credentials.exceptions.GetCredentialProviderConfigurationException
import androidx.credentials.exceptions.GetCredentialUnknownException
import androidx.credentials.exceptions.GetCredentialUnsupportedException
import androidx.credentials.exceptions.NoCredentialException
import androidx.credentials.exceptions.publickeycredential.CreatePublicKeyCredentialDomException
import androidx.credentials.exceptions.publickeycredential.GetPublicKeyCredentialDomException
import com.google.gson.Gson
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import android.util.Log

class ReactNativePasskeysModule : Module() {

    private val mainScope = CoroutineScope(Dispatchers.Default)
    companion object {
        private const val TAG = "RNPasskeys"
    }

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
            val credentialManager =
                CredentialManager.create(appContext.reactContext?.applicationContext!!)
            val json = Gson().toJson(request)
            val createPublicKeyCredentialRequest = CreatePublicKeyCredentialRequest(json)

            mainScope.launch {
                try {
                    val activity = appContext.currentActivity
                    if (activity == null) {
                        promise.reject("Passkey Create", "No current activity", null)
                        return@launch
                    }
                    val result = credentialManager.createCredential(activity, createPublicKeyCredentialRequest)
                    val response = result?.data?.getString("androidx.credentials.BUNDLE_KEY_REGISTRATION_RESPONSE_JSON")
                    val createCredentialResponse =
                        Gson().fromJson(response, RegistrationResponseJSON::class.java)
                    promise.resolve(createCredentialResponse)
                } catch (e: CreateCredentialException) {
                    Log.e(TAG, "create(): CreateCredentialException: ${e.javaClass.simpleName}: ${e.message}", e)
                    promise.reject("Passkey Create", getRegistrationException(e), e)
                } catch (t: Throwable) {
                    Log.e(TAG, "create(): Unexpected throwable: ${t.javaClass.simpleName}: ${t.message}", t)
                    promise.reject("Passkey Create", t.message, t)
                }
            }
        }

        AsyncFunction("get") { request: PublicKeyCredentialRequestOptions, promise: Promise ->
            val credentialManager =
                CredentialManager.create(appContext.reactContext?.applicationContext!!)
            val json = Gson().toJson(request)
            Log.d(TAG, "get()): json to GetPublicKeyCredentialOption= $json")
            val getCredentialRequest =
                GetCredentialRequest(listOf(GetPublicKeyCredentialOption(json)))

            mainScope.launch {
                try {
                    val activity = appContext.currentActivity
                    if (activity == null) {
                        Log.e(TAG, "get(): currentActivity is null")
                        promise.reject("Passkey Get", "No current activity", null)
                        return@launch
                    }

                    val result = credentialManager.getCredential(activity, getCredentialRequest)
                    val dataKeys = result?.credential?.data?.keySet()?.joinToString(", ") ?: "<no keys>"
                    val response =
                        result?.credential?.data?.getString("androidx.credentials.BUNDLE_KEY_AUTHENTICATION_RESPONSE_JSON")
                    Log.d(TAG, "get(): response JSON content = $response")
                    
                    val createCredentialResponse =
                        Gson().fromJson(response, AuthenticationResponseJSON::class.java)
                    promise.resolve(createCredentialResponse)
                } catch (e: GetCredentialException) {
                    Log.e(TAG, "get(): GetCredentialException: ${e.javaClass.simpleName}: ${e.message}", e)
                    val mapped = getAuthenticationException(e)
                    Log.e(TAG, "get(): mapped auth exception = $mapped")
                    promise.reject("Passkey Get", mapped, e)
                } catch (t: Throwable) {
                    Log.e(TAG, "get(): Unexpected throwable: ${t.javaClass.simpleName}: ${t.message}", t)
                    promise.reject("Passkey Get", t.message, t)
                }
            }
        }
    }

    private fun getRegistrationException(e: CreateCredentialException) =
        when (e) {
            is CreatePublicKeyCredentialDomException -> {
                e.domError.toString()
            }

            is CreateCredentialCancellationException -> {
                "UserCancelled"
            }

            is CreateCredentialInterruptedException -> {
                "Interrupted"
            }

            is CreateCredentialProviderConfigurationException -> {
                "NotConfigured"
            }

            is CreateCredentialUnknownException -> {
                "UnknownError"
            }

            is CreateCredentialUnsupportedException -> {
                "NotSupported"
            }

            else -> e.toString()
        }

    private fun getAuthenticationException(e: GetCredentialException) =
        when (e) {
            is GetPublicKeyCredentialDomException -> {
                e.domError.toString()
            }

            is GetCredentialCancellationException -> {
                "UserCancelled"
            }

            is GetCredentialInterruptedException -> {
                "Interrupted"
            }

            is GetCredentialProviderConfigurationException -> {
                "NotConfigured"
            }

            is GetCredentialUnknownException -> {
                "UnknownError"
            }

            is GetCredentialUnsupportedException -> {
                "NotSupported"
            }

            is NoCredentialException -> {
                "NoCredentials"
            }

            else -> {
                e.toString()
            }
        }
}
