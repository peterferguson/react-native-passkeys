import ExpoModulesCore

internal class NotConfiguredException: Exception {
  override var reason: String {
    "Your Apple app site association is not properly configured."
  }
}

internal class PendingPasskeyRequestException: Exception {
  override var reason: String {
    "There is already a pending passkey request"
  }
}

internal class NotSupportedException: Exception {
  override var reason: String {
    "Passkeys are not supported on this iOS version. Please use iOS 15 or above"
  }
}

internal class BiometricException: Exception {
  override var reason: String {
    "Biometrics must be enabled"
  }
}

internal class UserCancelledException: Exception {
  // Don't override reason - use the description passed to the initializer
  // Maps to WebAuthn NotAllowedError
}

internal class InvalidChallengeException: Exception {
  override var reason: String {
    "The provided challenge was invalid"
  }
}

internal class MissingUserIdException: Exception {
  override var reason: String {
    "`userId` is required"
  }
}

internal class InvalidUserIdException: Exception {
  override var reason: String {
    "The provided userId was invalid"
  }
}

internal class PasskeyRequestFailedException: Exception {
  override var reason: String {
    "The passkey request request failed"
  }
}

internal class PasskeyAuthorizationFailedException: Exception {
  override var reason: String {
    "The passkey authorization failed"
  }
}

internal class InvalidPRFInputException: Exception {
  override var reason: String {
    "The provided PRF input was invalid"
  }
}

internal class UnknownException: Exception {
  // Don't override reason - use the description passed to the initializer
  // This allows propagating the actual error message from ASAuthorizationError
}

internal class InvalidLargeBlobWriteInputException: Exception {
  override var reason: String {
    "The provided large blob write input was invalid"
  }
}

internal class MatchedExcludedCredentialException: Exception {
  // Don't override reason - use the description passed to the initializer
  // This will contain the localized message from iOS about the matched credential
}

internal class InvalidResponseException: Exception {
  // Don't override reason - use the description passed to the initializer
  // Maps to WebAuthn EncodingError
}

internal class NotHandledException: Exception {
  // Don't override reason - use the description passed to the initializer
  // Maps to WebAuthn NotSupportedError
}

internal class NotInteractiveException: Exception {
  // Don't override reason - use the description passed to the initializer
  // Maps to WebAuthn InvalidStateError
}
