import ExpoModulesCore

public class ExpoPasskeysModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoPasskeys")

    Function("hello") {
      return "Hello world! 👋"
    }

  }
}
