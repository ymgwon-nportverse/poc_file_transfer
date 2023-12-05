//
//  Constants.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#endif
import NearbyConnections


class Constants {
    static let nearbyConnectionsMethodChannel = "nearby_connections" // 공통적인 nearby 메소드 채널
    static let serviceId = "com.nportverse.poc" //앱에서 둘러볼 서비스 유형 목록이 있는 NSBonjourServices 키 추가. info.plist (Bonjour services: _D4820AFB1467._tcp ) 참고
    static let defaultStrategy = Strategy.pointToPoint // 다양한 탐색 전략 1.Cluster(M-N-N 또는 클러스터 형태의 연결 토폴로지를 지원하는 P2P 전략) 2.Star(1대1 또는 별 모양의 연결 토폴로지를 지원하는 P2P 전략) 3.Point-to-Point (1:1 연결 토폴로지를 지원하는 P2P 전략)

    static let defaultEndpointName = UIDevice.current.name // 연결하는 디바이스 이름 정보
    
    // method call 부분 ( flutter -> ios)
    static let startDiscovery = "startDiscovery" // nearby 활성화 되어있는 연결 기기를 찾는 메소드
    static let startAdvertising = "startAdvertising" //  nearby 연결 기기에게 활성화 상태를 알려주는 메소드
    static let stopDiscovery = "stopDiscovery" // 연결 기기를 찾는 동작을 멈추는 메소드
    static let stopAdvertising = "stopAdvertising" // 연결기기에게 비활성화 상태를 알려주는 메소드
    static let stopAllEndpoints = "stopAllEndpoints" // endpoint 동작을 멈춤
    static let disconnectFromEndpoint = "disconnectFromEndpoint" // 지정된 endpoint로 연결 해제
    static let acceptConnection = "acceptConnection" // 연결 수락
    static let requestConnection = "requestConnection" // 연결 요청
    static let rejectConnection = "rejectConnection" // 연결을 거절
    static let sendPayload = "sendPayload" // 페이로드를 보냄
    static let cancelPayload = "cancelPayload" // 페이로드 연결을 취소
    
    
    // invokeMethod call 부분 ( ios -> flutter )
    static let  onConnectionInitiated  = "onConnectionInitiated" // 연결 초기상태
    static let  onConnectionResult  = "onConnectionResult" // 연결 결과
    static let  onDisconnected  = "onDisconnected" // 연결 해제
    static let  onEndpointFound  = "onEndpointFound" // endpoint 찾음
    static let  onEndpointLost  = "onEndpointLost" // endpoint 연결 헤제
    static let  onPayloadReceived  = "onPayloadReceived" // payload를 받음
    static let  onPayloadTransferUpdate  = "onPayloadTransferUpdate" // payload 보내고 통신시 상태를 업데이트 시켜줌 
}
