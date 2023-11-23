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
    var type: PayloadType
    var status: Status
    let isIncoming: Bool
    let cancellationToken: CancellationToken?

    enum PayloadType {
        case bytes, stream, file
    }
    enum Status {
        case inProgress(Progress), success, failure, canceled
    }
}


//let uintInt8List =  call.arguments as! FlutterStandardTypedData
 //      let byte = [UInt8](uintInt8List.data)
