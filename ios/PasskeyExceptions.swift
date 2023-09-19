import ExpoModulesCore

internal class NotConfiguredException: Exception {
  override var reason: String {
    "Your Apple app site association is not properly configured."
  }
}

internal class NotSupportedException: Exception {
  override var reason: String {
    "Paskeys are not supported on this iOS version. Please use iOS 15 or above"
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
