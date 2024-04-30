import UIKit
import Flutter
import GoogleMaps
import flutter_background_service_ios

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "your.custom.task.identifier"
    GMSServices.provideAPIKey("AIzaSyDfu2SB5FCNWamT8Lsl0DbyYZ0wOlxQmY8")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
