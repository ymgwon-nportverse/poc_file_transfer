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
    var flutterMethodChannel: FlutterMethodChannel!
    
    public let name: String
    public let flutterWindow: UIWindow!
    
    public init(name: String,flutterWindow: UIWindow!) {
        self.flutterWindow = flutterWindow
        self.name = name
        flutterViewController = (self.flutterWindow.rootViewController as! FlutterViewController)
        flutterMethodChannel = FlutterMethodChannel(name: self.name, binaryMessenger: flutterViewController.binaryMessenger)
    }
    
    func callHandler() {
        flutterMethodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            var args =  call.arguments
            let flutterNearbyMethodCallName = FlutterNearbyMethodCallName(rawValue: call.method as String)
            let flutterPlatformChannelBridge = FlutterPlatformChannelBridge (callName: flutterNearbyMethodCallName,args:args as? Dictionary<String, Any> ,channel: self.flutterMethodChannel)
            flutterPlatformChannelBridge.doAction()
        })
    }
    
}
