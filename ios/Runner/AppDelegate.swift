import Flutter
import UIKit
import NearbyConnections
import OSLog

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override init() {
        super.init()
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        do {
            let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
            let bridge :FlutterBridge = FlutterBridge(controller: controller)
           
          try  bridge.connectBridge()
            
        }catch{
            os_log(.error, log: .default, "[AppDelegate]__\(error)")
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}
