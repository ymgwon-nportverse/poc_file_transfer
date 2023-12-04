//
//  connectionManager.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections


extension NearByConnectionController: ConnectionManagerDelegate {
    func connectionManager(_ connectionManager: ConnectionManager, didReceive verificationCode: String, from endpointID: EndpointID, verificationHandler: @escaping (Bool) -> Void) {
        
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
            payloadStatus: .success,
            isIncoming: true,
            cancellationToken: nil
        )
        
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        
        connections[index].payloads.insert(payload, at: 0)
        nearbyConnectionsInvokeEvent.onPayloadReceived(endpointId: endpointID, payloadType: payload.type.toString, bytes: data, payloadId: Int(payloadID), filePath: "")
        nearbyConnectionsInvokeEvent.onPayloadTransferUpdate(endpointId: endpointID, payloadId: payloadID, payloadStatus: payload.payloadStatus.toString, bytesTransferred: data.count, totalBytes: data.count)
    }
    
    func connectionManager(_ connectionManager: ConnectionManager, didReceive stream: InputStream, withID payloadID: PayloadID, from endpointID: EndpointID, cancellationToken token: CancellationToken) {
        let payload = Payload(
            id: payloadID,
            type: .stream,
            payloadStatus: .success,
            isIncoming: true,
            cancellationToken: token
        )
        
        guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
            return
        }
        
        connections[index].payloads.insert(payload, at: 0)
    }
    
    func connectionManager(_ connectionManager: ConnectionManager, didStartReceivingResourceWithID payloadID: PayloadID, from endpointID: EndpointID, at localURL: URL, withName name: String, cancellationToken token: CancellationToken) {
        let payload = Payload(
            id: payloadID,
            type: .file,
            payloadStatus: .inProgress,
            isIncoming: true,
            cancellationToken: token
        )
        
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
        
        switch update {
        case .success:
            connections[connectionIndex].payloads[payloadIndex].payloadStatus = .success
        case .canceled:
            connections[connectionIndex].payloads[payloadIndex].payloadStatus = .canceled
        case .failure:
            connections[connectionIndex].payloads[payloadIndex].payloadStatus = .failure
        case let .progress(progress):
            connections[connectionIndex].payloads[payloadIndex].payloadStatus = .inProgress
        }
        
    }
    
    func connectionManager(_ connectionManager: ConnectionManager, didChangeTo state: ConnectionState, for endpointID: EndpointID) {
        switch (state) {
        case .connecting:
            nearbyConnectionsInvokeEvent.onConnectionInitiated(endpointId: endpointID, endpointName: endpointName ,authenticationDigits: "", isIncomingConnection: true)
            break
        case .connected:
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
            nearbyConnectionsInvokeEvent.onConnectionResult(endpointId: endpointID, status: ConnectionStatus.connected)
        case .disconnected:
            
            guard let index = connections.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            //           connections.remove(at: index)
            connections.removeAll()
            nearbyConnectionsInvokeEvent.onDisconnected(endpointId: endpointID)
        case .rejected:
            
            guard let index = requests.firstIndex(where: { $0.endpointID == endpointID }) else {
                return
            }
            
            requests.remove(at: index)
        }
    }
}
