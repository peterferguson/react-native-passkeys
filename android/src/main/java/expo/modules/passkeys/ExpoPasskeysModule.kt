package expo.modules.passkeys

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoPasskeysModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("ExpoPasskeys")

    Function("isSupported") {
      "get world! 👋"
    }


    Function("get") {
      "get world! 👋"
    }

    Function("create") {
      "create world! 👋"
    }
  }
}
