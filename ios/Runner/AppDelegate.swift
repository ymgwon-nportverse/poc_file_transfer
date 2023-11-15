import Flutter
import UIKit
import NearbyConnections

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "nearby_connections", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            if(call.method == "startDiscovery"){
                if let args = call.arguments as? Dictionary<String, Any> {
                    let  serviceId  = args["serviceId"] as? String
                    let  strategy = args["strategy"] as? Int
                    let  userName = args["userName"] as? String
                    print("service => \(serviceId) , strategy => \(strategy) , usename => \(userName)")
                   
                    let endPointargs : [String: Any?] = ["endpointId": "test id","endpointName": "test name","authenticationDigits":"test authenticationDigits","isIncomingConnection":true]
                    channel.invokeMethod("onDiscoveryConnectionInitiated", arguments: endPointargs)
                  }
            }else{
                print("call.method => \(call.method)")
            }
            
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}



