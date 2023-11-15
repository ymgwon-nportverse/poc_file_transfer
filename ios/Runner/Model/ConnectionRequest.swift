//
//  ConnectionRequest.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

struct ConnectionRequest: Identifiable {
    let id: UUID
    let endpointID: EndpointID
    let endpointName: String
    let pin: String
    let shouldAccept: ((Bool) -> Void)
}
