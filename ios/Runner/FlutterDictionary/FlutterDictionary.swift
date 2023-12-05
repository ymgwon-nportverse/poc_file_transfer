//
//  FlutterDictionary.swift
//  Runner
//
//  Created by ahhyun lee on 12/1/23.
//

import Foundation
import Flutter
import UIKit
import OSLog

class FlutterDictionary:FlutterDictionaryDelegate{
    var dict: Dictionary<String, FlutterChannelDelegate> = [Constants.nearbyConnectionsMethodChannel:NearbyConnectionsChannel()]
    
    
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
    
    
    func connectDictionary(){
        do{
        let channels  = registerChannel()
            try channels.forEach{
                $0.setMethodCallHandler()
            }
        }catch{
            os_log(.error, log: .default, "[FlutterDictionary]__\(error)")
        }
    }
}
