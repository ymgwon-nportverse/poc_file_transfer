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

}
