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
    var payloadStatus: PayloadStatus
    let isIncoming: Bool
    let cancellationToken: CancellationToken?

    enum PayloadType{
        case bytes, stream, file
    }
    
    enum PayloadStatus {
        case inProgress, success, failure, canceled
    }
    
}

extension Payload.PayloadType{
    var toString:String {
        switch self{
        case .bytes: return "bytes"
        case .stream: return "stream"
        case .file : return "file"
        }
    }
}

extension Payload.PayloadStatus{
    var toString:String {
        switch self{
        case .inProgress : return "inProgress"
        case .success : return "success"
        case .failure : return "failure"
        case .canceled : return "canceled"
        }
    }
}
