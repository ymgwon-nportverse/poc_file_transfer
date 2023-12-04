//
//  File.swift
//  Runner
//
//  Created by ahhyun lee on 12/1/23.
//

import Foundation
import Flutter
import UIKit

protocol FlutterBridgeDelegate{
    func callback(call: FlutterMethodCall, result: @escaping FlutterResult)
}



