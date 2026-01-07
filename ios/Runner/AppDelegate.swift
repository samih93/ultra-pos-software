import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let versionChannel = FlutterMethodChannel(name: "com.core.manager/version",
                                              binaryMessenger: controller.binaryMessenger)
    
    versionChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      
      if call.method == "getVersionCode" {
        result(self.getVersionCode())
      } else if call.method == "getVersionName" {
        result(self.getVersionName())
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func getVersionCode() -> String {
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      return build
    }
    return "Unknown"
  }
  
  private func getVersionName() -> String {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      return version
    }
    return "Unknown"
  }
}
