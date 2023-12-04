//
//  FlutterBridge.swift
//  Runner
//
//  Created by ahhyun lee on 12/1/23.
//

import Foundation
import Flutter
import UIKit

class FlutterBridge:FlutterBridgeDictionaryDelegate{
    var dict: Dictionary<String, FlutterChannelDelegate> = [Constants.methodChannelName:NearbyConnectionsChannel()]
    
    
    init(controller: FlutterViewController) {
        self.controller = controller
    }
    
    let controller : FlutterViewController
    
    
    private func registerChannel()->[FlutterChannelConnector]{
        var result: [FlutterChannelConnector] = []
        
        for item in dict {
            var channel = FlutterChannelConnector(flutterViewController: controller, channelName: item.key ,flutterChannel: item.value)
            result.append(channel)
        }
        
        return result
    }
    
    
 func connectBridge(){
     let channels  = registerChannel()
        channels.forEach{
            $0.setMethodCallHandler()
        }
    }
    
}
