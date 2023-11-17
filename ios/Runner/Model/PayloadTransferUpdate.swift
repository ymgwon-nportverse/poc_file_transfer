//
//  PayloadTransferUpdate.swift
//  Runner
//
//  Created by ahhyun lee on 11/16/23.
//

import Foundation
import NearbyConnections

// 추가
struct PayloadTransferUpdate {
    let id: PayloadID
    let bytesTransferred: Int
    let totalBytes: Int
    var status: PayloadStatus
}
