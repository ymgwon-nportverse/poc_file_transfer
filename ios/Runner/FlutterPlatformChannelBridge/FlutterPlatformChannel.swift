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
    
}


extension FlutterPlatformChannel {
    
    func setMethodcallHandler() {
        
        //todo : flutter result 처리
        flutterMethodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let flutterNearbyMethodCallName = FlutterNearbyMethodCallName(rawValue: call.method as String)
            flutterNearbyMethodCallName?.methodCall.callback((call.arguments as? Dictionary<String, Any>), channel: self.flutterMethodChannel)
            flutterNearbyMethodCallName?.methodCall.printCallBackName(name: call.method) // todo : 임시 로그
        })
        
    }
}
