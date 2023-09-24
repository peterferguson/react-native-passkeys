package expo.modules.passkeys

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

import androidx.credentials.CredentialManager
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption


class ReactNativePasskeysModule : Module() {
  private val mainScope = CoroutineScope(Discontextpatchers.Default)

  private lateinit var  credentialManager: CredentialManager 

  override fun definition() = ModuleDefinition {
    Name("ReactNativePasskeys")

    OnCreate {
      credentialManager = CredentialManager.getInstance(appContext.reactContext)
    }

    Function("isSupported") {
      "get world! 👋"
    }

    Function("isAutoFillAvailable") {
      false
    }

    AsyncFunction("create") { request: String, promise: Promise ->
      
    }

    AsyncFunction("get") { request: String, promise: Promise ->
      launch(Dispatchers.Main) {
        promise.resolve(request)
      }
    }
  }

  private fun createPasskey(request: String, promise: Promise ): String {
    launch(Dispatchers.Main) {
      




      promise.resolve(request)
    }
  }

  private fun getPasskey(request: String): String {}
}
