import Flutter
import NearbyConnections
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override init() {
        connectionManager = ConnectionManager(serviceID: "com.nportverse.poc", strategy: .pointToPoint)
        advertiser = Advertiser(connectionManager: connectionManager)
        discoverer = Discoverer(connectionManager: connectionManager)
    }
    
    let connectionManager: ConnectionManager
    let advertiser: Advertiser
    let discoverer: Discoverer


    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.nportverse.poc",
            binaryMessenger: controller.binaryMessenger
        )
        
        // Nearby 관련 이벤트 처리하는 곳
        let nearbyHandler : NearbyHandler = NearbyHandler(channel: channel)
        // 내부에서 channel.setMethodHandler 사용하고 있음
        nearbyHandler.setMethodCallback()
        

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

}
