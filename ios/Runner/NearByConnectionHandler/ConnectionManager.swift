//
//  connectionManager.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

extension NearByConnectionHandler: ConnectionManagerDelegate {
    func connectionManager(_ connectionManager: ConnectionManager, didReceive verificationCode: String, from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
        print("========================================= connectionManager_1 ")
        guard let index = endpoints.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        let endpoint = endpoints.remove(at: index)
        let request = ConnectionRequest(
            id: endpoint.id,
            endpointID: endpointID,
            endpointName: endpoint.endpointName,
            pin: verificationCode,
            shouldAccept: { accept in
                verificationHandler(accept)
            }
        )
        requests.insert(request, at: 0)
    }

    func connectionManager(_ connectionManager: ConnectionManager, didReceive data: Data, withID payloadID: PayloadID, from endpointID: EndpointID) {
        let payload = Payload(
            id: payloadID,
            type: .bytes,
            status: .success,
            isIncoming: true,
            cancellationToken: nil
        )
        print("========================================= connectionManager_2")
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        connections[index].payloads.insert(payload, at: 0)
    }

    func connectionManager(_ connectionManager: ConnectionManager, didReceive stream: InputStream, withID payloadID: PayloadID, from endpointID: EndpointID, cancellationToken token: CancellationToken) {
        let payload = Payload(
            id: payloadID,
            type: .stream,
            status: .success,
            isIncoming: true,
            cancellationToken: token
        )
        print("========================================= connectionManager_3")
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        connections[index].payloads.insert(payload, at: 0)
    }

    func connectionManager(_ connectionManager: ConnectionManager, didStartReceivingResourceWithID payloadID: PayloadID, from endpointID: EndpointID, at localURL: URL, withName name: String, cancellationToken token: CancellationToken) {
        let payload = Payload(
            id: payloadID,
            type: .file,
            status: .inProgress(Progress()),
            isIncoming: true,
            cancellationToken: token
        )
        print("========================================= connectionManager_4")
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        connections[index].payloads.insert(payload, at: 0)
    }

    func connectionManager(_ connectionManager: ConnectionManager, didReceiveTransferUpdate update: TransferUpdate, from endpointID: EndpointID, forPayload payloadID: PayloadID) {
        guard let connectionIndex = connections.firstIndex(where: { $0.endpointID == endpointID }),
              let payloadIndex = connections[connectionIndex].payloads.firstIndex(where: { $0.id == payloadID }) else {
            return
        }
        print("========================================= connectionManager_5")
        switch update {
        case .success:
            connections[connectionIndex].payloads[payloadIndex].status = .success
        case .canceled:
            connections[connectionIndex].payloads[payloadIndex].status = .canceled
        case .failure:
            connections[connectionIndex].payloads[payloadIndex].status = .failure
        case let .progress(progress):
            connections[connectionIndex].payloads[payloadIndex].status = .inProgress(progress)
        }
    }

    func connectionManager(_ connectionManager: ConnectionManager, didChangeTo state: ConnectionState, for endpointID: EndpointID) {
        switch (state) {
        case .connecting:
            print("=================[connected_0]======================== ");
            break
        case .connected:
            print("=================[connected_1]======================== ");
            guard let index = requests.firstIndex(where: { $0.endpointID == endpointID }) else {
            
                return
            }
            let request = requests.remove(at: index)
            let connection = ConnectedEndpoint(
                id: request.id,
                endpointID: endpointID,
                endpointName: request.endpointName
            )

            connections.insert(connection, at: 0)
        case .disconnected:
            print("=================[disconnected]======================== ")
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            connections.remove(at: index)
        case .rejected:
            print("=================[rejected]======================== ")
            guard let index = requests.firstIndex(where: { $0.endpointID == endpointID }) else {

                return
            }
            requests.remove(at: index)
        }
        print("========================================= connectionManager_6 \(state)")
    }
}
