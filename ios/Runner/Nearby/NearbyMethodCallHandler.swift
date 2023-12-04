import Flutter
import NearbyConnections

class NearbyMethodCallHandler: MethodCallHandler {
    private var connectionManager: ConnectionManager
    private var discoverer: Discoverer
    private var advertiser: Advertiser
    let methodChannel: FlutterMethodChannel

    private let serviceId: String = "com.nportverse.poc"
    private var strategy: Strategy = .pointToPoint

    init(viewController: FlutterViewController) {
        methodChannel = FlutterMethodChannel(
            name: "nearby_connections", binaryMessenger: viewController.binaryMessenger
        )
        connectionManager = ConnectionManager(serviceID: serviceId, strategy: strategy)
        discoverer = Discoverer(connectionManager: connectionManager)
        advertiser = Advertiser(connectionManager: connectionManager)
        discoverer.delegate = self
        advertiser.delegate = self
    }

    public func setHandler() {
        methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "startAdvertising":
                print("startAdvertising")
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError())
                    return
                }
                guard let userName = args["userName"] as? String else {
                    result(FlutterInvalidArgumentError())
                    return
                }
                guard let strategyName = args["strategy"] as? String else {
                    result(FlutterInvalidArgumentError())
                    return
                }

                let newStrategy = Strategy.byName(name: strategyName)
                if newStrategy != self.strategy {
                    self.configureConnection(strategy: newStrategy)
                }

                self.advertiser.startAdvertising(using: Data(userName.utf8)) { (error: Error?) in
                    result(
                        FlutterError(
                            code: "START_ADVERTISING_FAILURE", message: error?.localizedDescription, details: nil
                        )
                    )
                }

            case "startDiscovery":
                print("startDiscovery")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError())
                    return
                }
                guard let strategyName = args["strategy"] as? String else {
                    result(FlutterInvalidArgumentError())
                    return
                }
                let newStrategy = Strategy.byName(name: strategyName)
                if newStrategy != self.strategy {
                    self.configureConnection(strategy: newStrategy)
                }

                self.discoverer.startDiscovery { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "START_DISCOVERY_FAILURE", message: error?.localizedDescription, details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "stopAdvertising":
                print("stopAdvertising")
                self.advertiser.stopAdvertising { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "STOP_ADVERTISING_FAILURE", message: error?.localizedDescription, details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "stopDiscovery":
                print("stopDiscovery")
                self.discoverer.stopDiscovery { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "STOP_DISCOVERY_FAILURE", message: error?.localizedDescription, details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "stopAllEndpoints":
                print("stopAllEndpoints")

            case "disconnectFromEndpoint":
                print("disconnectFromEndpoint")
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError())
                    return
                }

                guard let endpointId = args["endpointId"] as? String else {
                    result(FlutterInvalidArgumentError())
                    return
                }
                self.connectionManager.disconnect(from: endpointId) { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "DISCONNECT_FROM_ENDPOINT_FAILURE",
                                message: error?.localizedDescription,
                                details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "requestConnection":
                print("requestConnection")

                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterInvalidArgumentError())
                    return
                }

                guard let endpointId = args["endpointId"] as? String else {
                    result(FlutterInvalidArgumentError())
                    return
                }

                guard let userName = args["userName"] as? String else {
                    result(FlutterInvalidArgumentError())
                    return
                }

                self.discoverer.requestConnection(
                    to: endpointId,
                    using: userName.data(using: .utf8)!
                ) { (error: Error?) in
                    if error != nil {
                        result(
                            FlutterError(
                                code: "REQUEST_CONNECTION_FAILURE",
                                message: error?.localizedDescription,
                                details: nil
                            )
                        )
                    }
                    result(nil)
                }

            case "acceptConnection":
                print("acceptConnection")

                // TODO: 다음 코드는 internal protocol 이라 사용할 수 없으니 방법 찾기
                // self.advertiser.connection?.acceptedConnection(toEndpoint: "")

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func configureConnection(strategy newStrategy: Strategy) {
        strategy = newStrategy
        connectionManager = ConnectionManager(serviceID: serviceId, strategy: strategy)
        discoverer = Discoverer(connectionManager: connectionManager)
        advertiser = Advertiser(connectionManager: connectionManager)
        discoverer.delegate = self
        advertiser.delegate = self
    }
}

class FlutterInvalidArgumentError: FlutterError {
    override var code: String {
        "INVALID_ARGUMENTS_FORMAT"
    }

    override var description: String {
        "The arguments passed to native is not what you promised"
    }
}

extension Strategy {
    static func byName(name: String) -> Strategy {
        switch name {
        case "pointToPoint": return .pointToPoint
        case "cluster": return .cluster
        case "star": return .star
        default: fatalError("unknown name for strategy")
        }
    }
}
