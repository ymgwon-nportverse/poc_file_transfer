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
        
        let flutterPlatformChannel: FlutterPlatformChannel = FlutterPlatformChannel(channelName: Constants.methodChannelName, flutterWindow: window)
        
        flutterPlatformChannel.FlutterMethodCallBack()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}


