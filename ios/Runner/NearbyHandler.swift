import Flutter
import NearbyConnections


class NearbyHandler {
    let connectionManager: ConnectionManager
    let discoverer: Discoverer
    let advertiser: Advertiser
    let methodChannel: FlutterMethodChannel

    init(channel:FlutterMethodChannel) {
        self.methodChannel=channel
        connectionManager = ConnectionManager(serviceID: "com.nportverse.poc", strategy: .pointToPoint)
        discoverer = Discoverer(connectionManager: connectionManager)
        advertiser = Advertiser(connectionManager: connectionManager)
        
        connectionManager.delegate = self
        discoverer.delegate = self
        advertiser.delegate = self
    }
    
    func setMethodCallback() {
        methodChannel.setMethodCallHandler{ (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch (call.method) {
                
            case "startAdvertising":
                print("startAdvertising")
                guard let args = call.arguments as? Dictionary<String, Any> else {
                   // TODO: error 내보내기
                    return
                }
                
                guard  let userName = args["userName"] as? String else  {
                   // TODO: error 내보내기
                    return
                }
                         
                self.advertiser.startAdvertising(using: Data(userName.utf8) ) {
                    (call: Error?) in
                    // TODO: 확인해보고 처리
                }
                
            case "startDiscovery":
                print("startDiscovery")
                self.discoverer.startDiscovery {
                    (call: Error?) in
                    // TODO: 확인해보고 처리
                }
                
            case "stopAdvertising":
                print("stopAdvertising")
                self.advertiser.stopAdvertising{
                    (call: Error?) in
                    // TODO: 확인해보고 처리
                }
                
            case "stopDiscovery":
                print("stopDiscovery")
                self.discoverer.stopDiscovery{
                    (call: Error?) in
                    // TODO: 확인해보고 처리
                }
                
            // TODO: `stopAllEndpoints` 는 swift에 API 존재하지 않으니 방법 찾기
                
            case "disconnectFromEndpoint":
                print("disconnectFromEndpoint")
                guard let args = call.arguments as? Dictionary<String, Any> else {
                   // TODO: error 내보내기
                    return
                }
                
                guard  let endpointId = args["endpointId"] as? String else  {
                   // TODO: error 내보내기
                    return
                }
                self.connectionManager.disconnect(from: endpointId) {
                    (call: Error?) in
                    // TODO: 확인해보고 처리
                }
                
            case "requestConnection":
                print("disconnectFromEndpoint")
                // TODO: arguments 제대로 넣어서 처리하기
                self.discoverer.requestConnection(to: <#T##EndpointID#>, using: <#T##Data#>)
            
            case "acceptConnection":
                print("acceptConnection")
                // TODO: 다음 코드는 internal protocol 이라 사용할 수 없으니 방법 찾기
                // self.advertiser.connection?.acceptedConnection(toEndpoint: "")
                
                
            default:
                // TODO: error result 처리하기
                print("something went wrong")
            }
        }
    }
}

extension NearbyHandler: ConnectionManagerDelegate {
    func connectionManager(
        _: ConnectionManager, didReceive _: String,
        from _: EndpointID, verificationHandler: @escaping (Bool) -> Void
    ) {
        // Optionally show the user the verification code. Your app should call this handler
        // with a value of `true` if the nearby endpoint should be trusted, or `false`
        // otherwise.
        verificationHandler(true)
    }

    func connectionManager(
        _: ConnectionManager, didReceive _: Data,
        withID _: PayloadID, from _: EndpointID
    ) {
        // A simple byte payload has been received. This will always include the full data.
    }

    func connectionManager(
        _: ConnectionManager, didReceive _: InputStream,
        withID _: PayloadID, from _: EndpointID,
        cancellationToken _: CancellationToken
    ) {
        // We have received a readable stream.
    }

    func connectionManager(
        _: ConnectionManager,
        didStartReceivingResourceWithID _: PayloadID,
        from _: EndpointID, at _: URL,
        withName _: String, cancellationToken _: CancellationToken
    ) {
        // We have started receiving a file. We will receive a separate transfer update
        // event when complete.
    }

    func connectionManager(
        _: ConnectionManager,
        didReceiveTransferUpdate _: TransferUpdate,
        from _: EndpointID, forPayload _: PayloadID
    ) {
        // A success, failure, cancellation or progress update.
    }

    func connectionManager(
        _: ConnectionManager, didChangeTo state: ConnectionState,
        for _: EndpointID
    ) {
        switch state {
        case .connecting:
            // A connection to the remote endpoint is currently being established.
            print("connecting")
        case .connected:
            // We're connected! Can now start sending and receiving data.
            print("connected")
        case .disconnected:
            // We've been disconnected from this endpoint. No more data can be sent or received.
            print("disconnected")
        case .rejected:
            // The connection was rejected by one or both sides.
            print("rejected")
        }
    }
}

