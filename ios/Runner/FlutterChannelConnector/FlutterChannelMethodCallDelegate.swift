//
//  MethodCallDelegate.swift
//  Runner
//
//  Created by ahhyun lee on 12/4/23.
//

import Foundation
import Flutter
import UIKit

protocol FlutterChannelMethodCallDelegate{
    var handler: FlutterMethodCallHandler { get }
    func setMethodCallHandler()
}
