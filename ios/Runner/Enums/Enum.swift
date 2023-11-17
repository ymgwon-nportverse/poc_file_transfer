//
//  Enum.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
import NearbyConnections

enum PayloadType {
    case none,bytes, stream, file
}

enum ConnectionStatus {
case  connected,
      rejected,
      error
}

enum PayloadStatus {
    case inProgress(Progress), success, failure, canceled
}

enum MethodEvent {
    case onAdvertiseConnectionInitiated, // 1) 보내기 init
      onAdvertiseConnectionResult, // 2) 보내기 연결 결과
      onAdvertiseDisconnected, // 3) 보내기 연결 해제
      onDiscoveryConnectionInitiated, //  4) 받기 init
      onDiscoveryConnectionResult,  // 5) 받기 연결 결과
      onDiscoveryDisconnected,  // 6) 받기 연결 해제
      onEndpointFound, // 7) endpoint 찾음
      onEndpointLost, // 8) endpoint 해제
      onPayloadReceived, // 9) data 받음
      onPayloadTransferUpdate // 10) data 업데이트
}

enum BandwidthQuality {
    case  unknown,  low,  medium,  high
}


