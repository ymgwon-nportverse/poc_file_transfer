//
//  Payload.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

struct Payload: Identifiable {
    let id: PayloadID
    let type: PayloadType
    var bytes: [UInt8]?
    var filePath: String?
}

//let uintInt8List =  call.arguments as! FlutterStandardTypedData
 //      let byte = [UInt8](uintInt8List.data)
