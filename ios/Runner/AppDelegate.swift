import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let key = Self.mapsApiKeyFromSecrets() {
      GMSServices.provideAPIKey(key)
    } else {
      NSLog("Pannipe: missing GOOGLE_MAPS_API_KEY in Runner/Secrets.plist — copy Secrets.plist.example")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Reads Maps key from git-ignored `Secrets.plist` (never hardcode keys in source).
  private static func mapsApiKeyFromSecrets() -> String? {
    guard
      let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
      let dict = NSDictionary(contentsOf: url) as? [String: Any],
      let key = dict["GOOGLE_MAPS_API_KEY"] as? String,
      !key.isEmpty,
      !key.contains("your_google_maps")
    else {
      return nil
    }
    return key
  }
}
