import Flutter
import NearbyConnections

extension NearbyMethodCallHandler: DiscovererDelegate {
    func discoverer(
        _: Discoverer, didFind endpointID: EndpointID, with context: Data
    ) {
        // An endpoint was found.
        print("onEndpointFound")
        var args = [String: Any]()
        guard let endpointName = String(data: context, encoding: .utf8) else {
            return
        }
        args["endpointId"] = endpointID.data(using: .utf8)
        args["endpointName"] = endpointName
        methodChannel.invokeMethod("onEndpointFound", arguments: args)
    }

    func discoverer(_: Discoverer, didLose endpointID: EndpointID) {
        // A previously discovered endpoint has gone away.
        print("onEndpointLost")
        var args = [String: Any]()
        args["endpointId"] = endpointID.data(using: .utf8)
        methodChannel.invokeMethod("onEndpointLost", arguments: args)
    }
}
