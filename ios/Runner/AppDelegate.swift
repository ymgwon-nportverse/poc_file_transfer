import Flutter
import UIKit
import NearbyConnections

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override init() {
        super.init()
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let bridge :FlutterBridge = FlutterBridge(controller: controller)
       
        bridge.connectBridge()
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}
