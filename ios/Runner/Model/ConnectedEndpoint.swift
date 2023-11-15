//
//  ConnectedEndpoint.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

struct ConnectedEndpoint: Identifiable {
    let id: UUID
    let endpointID: EndpointID
    let endpointName: String
    var payloads: [Payload] = []
}
