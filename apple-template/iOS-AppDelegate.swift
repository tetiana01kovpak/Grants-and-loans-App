import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let grantBridge = GrantCalendarBridge()
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if let controller = window?.rootViewController as? FlutterViewController {
            grantBridge.register(messenger: controller.binaryMessenger)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
