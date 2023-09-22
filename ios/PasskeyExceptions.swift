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
  override var reason: String {
    "User cancelled the passkey interaction"
  }
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

internal class UnknownException: Exception {
  override var reason: String {
    "An unknown exception occured"
  }
}
