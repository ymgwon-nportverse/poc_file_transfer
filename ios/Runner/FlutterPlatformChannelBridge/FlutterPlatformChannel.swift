//
//  flutterChannel.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import Flutter
import UIKit

public class FlutterPlatformChannel: FlutterPlatformChannelDelegate{
    
    var flutterViewController: FlutterViewController!
    static var flutterMethodChannel: FlutterMethodChannel!
    
    public let name: String
    public let flutterWindow: UIWindow!
    
    public init(name: String,flutterWindow: UIWindow!) {
        self.flutterWindow = flutterWindow
        self.name = name
        flutterViewController = (self.flutterWindow.rootViewController as! FlutterViewController)
        FlutterPlatformChannel.flutterMethodChannel = FlutterMethodChannel(name: self.name, binaryMessenger: flutterViewController.binaryMessenger)
    }
    
    func callHandler() {
        FlutterPlatformChannel.flutterMethodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            var args =  call.arguments
            let flutterNearbyMethodCallName = FlutterNearbyMethodCallName(rawValue: call.method as String)
            let flutterPlatformChannelBridge = FlutterPlatformChannelBridge (callName: flutterNearbyMethodCallName,args:args as? Dictionary<String, Any> ,channel: FlutterPlatformChannel.flutterMethodChannel,result: result)
            flutterPlatformChannelBridge.doAction()
        })
    }
    
   static func invokeHandler(method:String,arguments:Dictionary<String, Any>?){
       FlutterPlatformChannel.flutterMethodChannel.invokeMethod(method, arguments: arguments)
   }
    
}


// 채널 프로토콜 만들기 
