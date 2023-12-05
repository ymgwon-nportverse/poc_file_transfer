//
//  c.swift
//  Runner
//
//  Created by ahhyun lee on 12/1/23.
//

import Foundation
import Flutter
import UIKit

protocol MethodCallDelegate{
    var handler: FlutterMethodCallHandler { get }
    func setMethodCallHandler()
}
