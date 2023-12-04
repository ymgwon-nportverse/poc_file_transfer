import Flutter
import NearbyConnections
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "nearby_connections",
            binaryMessenger: controller.binaryMessenger
        )

        let handlers: [MethodCallHandler] = [
            NearbyMethodCallHandler(viewController: controller),
        ]

        for handler in handlers {
            handler.setHandler()
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
