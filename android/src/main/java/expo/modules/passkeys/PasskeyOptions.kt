package expo.modules.crypto

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record
import expo.modules.kotlin.types.Enumerable

fun handlePasskeyException(exception: Either<GetCredentialException, CreateCredentialException>): String {
  exception.get(GetCredentialException::class).let {
     when (e) {
      is GetPublicKeyCredentialDomException -> {
        return e.domError.toString()
      }
      is GetCredentialCancellationException -> {
        return "UserCancelled"
      }
      is GetCredentialInterruptedException -> {
        return "Interrupted"
      }
      is GetCredentialProviderConfigurationException -> {
        return "NotConfigured"
      }
      is GetCredentialUnknownException -> {
        return "UnknownError"
      }
      is GetCredentialUnsupportedException -> {
        return "NotSupported"
      }
      is NoCredentialException -> {
        return "NoCredentials"
      }
      else -> {
        return e.toString()
      }
    }
  }
  exception.get(CreateCredentialException::class).let {
    when (e) {
          is CreatePublicKeyCredentialDomException -> {
            return e.domError.toString()
          }
          is CreateCredentialCancellationException -> {
            return "UserCancelled"
          }
          is CreateCredentialInterruptedException -> {
            return "Interrupted"
          }
          is CreateCredentialProviderConfigurationException -> {
            return "NotConfigured"
          }
          is CreateCredentialUnknownException -> {
            return "UnknownError"
          }
          is CreateCredentialUnsupportedException -> {
            return "NotSupported"
          }
          else -> {
            return e.toString()
          }
        }
  }
}