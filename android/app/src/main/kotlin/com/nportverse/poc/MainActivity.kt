package com.nportverse.poc

import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.AdvertisingOptions
import com.google.android.gms.nearby.connection.ConnectionInfo
import com.google.android.gms.nearby.connection.ConnectionLifecycleCallback
import com.google.android.gms.nearby.connection.ConnectionResolution
import com.google.android.gms.nearby.connection.ConnectionsStatusCodes
import com.google.android.gms.nearby.connection.DiscoveredEndpointInfo
import com.google.android.gms.nearby.connection.DiscoveryOptions
import com.google.android.gms.nearby.connection.EndpointDiscoveryCallback
import com.google.android.gms.nearby.connection.Payload
import com.google.android.gms.nearby.connection.PayloadCallback
import com.google.android.gms.nearby.connection.PayloadTransferUpdate
import com.google.android.gms.nearby.connection.Strategy
import com.google.android.gms.tasks.OnSuccessListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

const val SERVICE_ID = "flutter_nearby_connections"

const val NEARBY_RUNNING = "nearby_running"
const val METHOD_CHANNEL = "nearby_connections"

class MainActivity : FlutterActivity() {
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine,
    ) {
        super.configureFlutterEngine(flutterEngine)

        channel =
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                METHOD_CHANNEL,
            )

        channel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            try {
                // TODO: handle situations for each case
                when (call.method) {
                    "stopAdvertising" -> {
                        Log.d("nearby_connections", "stopAdvertising")
                        Nearby.getConnectionsClient((activity)!!).stopAdvertising()
                        result.success(null)
                    }

                    "stopDiscovery" -> {
                        Log.d("nearby_connections", "stopDiscovery")
                        Nearby.getConnectionsClient((activity)!!).stopDiscovery()
                        result.success(null)
                    }

                    "startAdvertising" -> {
                        val userNickName = call.argument<Any>("userNickName") as String?
                        val strategy = call.argument<Any>("strategy") as Int
                        var serviceId = call.argument<Any>("serviceId") as String?
                        assert(userNickName != null)
                        if (serviceId == null || serviceId === "") {
                            serviceId =
                                SERVICE_ID
                        }
                        val advertisingOptions =
                            AdvertisingOptions.Builder().setStrategy(getStrategy(strategy)).build()
                        Nearby.getConnectionsClient((activity)!!).startAdvertising(
                            (userNickName)!!,
                            serviceId,
                            advertConnectionLifecycleCallback,
                            advertisingOptions,
                        ).addOnSuccessListener(
                            OnSuccessListener {
                                Log.d("nearby_connections", "startAdvertising")
                                result.success(true)
                            },
                        ).addOnFailureListener { e ->
                            result.error(
                                "Failure",
                                e.message,
                                null,
                            )
                        }
                    }

                    "startDiscovery" -> {
                        val userNickName = call.argument<Any>("userNickName") as String?
                        val strategy = call.argument<Any>("strategy") as Int
                        var serviceId = call.argument<Any>("serviceId") as String?
                        assert(userNickName != null)
                        if (serviceId == null || serviceId === "") {
                            serviceId =
                                SERVICE_ID
                        }
                        val discoveryOptions =
                            DiscoveryOptions.Builder().setStrategy(getStrategy(strategy)).build()
                        Nearby.getConnectionsClient((activity)!!)
                            .startDiscovery(serviceId, endpointDiscoveryCallback, discoveryOptions)
                            .addOnSuccessListener {
                                Log.d("nearby_connections", "startDiscovery")
                                result.success(true)
                            }.addOnFailureListener { e ->
                                result.error(
                                    "Failure",
                                    e.message,
                                    null,
                                )
                            }
                    }

                    "stopAllEndpoints" -> {
                        Log.d("nearby_connections", "stopAllEndpoints")
                        Nearby.getConnectionsClient((activity)!!).stopAllEndpoints()
                        result.success(null)
                    }

                    "disconnectFromEndpoint" -> {
                        Log.d("nearby_connections", "disconnectFromEndpoint")
                        val endpointId = call.argument<String>("endpointId")
                        assert(endpointId != null)
                        Nearby.getConnectionsClient((activity)!!)
                            .disconnectFromEndpoint((endpointId)!!)
                        result.success(null)
                    }

                    "requestConnection" -> {
                        Log.d("nearby_connections", "requestConnection")
                        val userNickName = call.argument<Any>("userNickName") as String?
                        val endpointId = call.argument<Any>("endpointId") as String?
                        assert(userNickName != null)
                        assert(endpointId != null)
                        Nearby.getConnectionsClient((activity)!!).requestConnection(
                            (userNickName)!!,
                            (endpointId)!!,
                            discoverConnectionLifecycleCallback,
                        ).addOnSuccessListener { result.success(true) }
                            .addOnFailureListener { e -> result.error("Failure", e.message, null) }
                    }

                    "acceptConnection" -> {
                        val endpointId = call.argument<Any>("endpointId") as String?
                        assert(endpointId != null)
                        Nearby.getConnectionsClient((activity)!!)
                            .acceptConnection((endpointId)!!, payloadCallback)
                            .addOnSuccessListener {
                                Log.d("nearby_connections", "acceptConnection")
                                result.success(true)
                            }.addOnFailureListener { e ->
                                result.error(
                                    "Failure",
                                    e.message,
                                    null,
                                )
                            }
                    }

                    "rejectConnection" -> {
                        val endpointId = call.argument<Any>("endpointId") as String?
                        assert(endpointId != null)
                        Nearby.getConnectionsClient((activity)!!).rejectConnection((endpointId)!!)
                            .addOnSuccessListener {
                                Log.d("nearby_connections", "rejectConnection")
                                result.success(true)
                            }.addOnFailureListener { e -> result.error("Failure", e.message, null) }
                    }

                    "sendPayload" -> {
                        val endpointId = call.argument<Any>("endpointId") as String?
                        val bytes = call.argument<ByteArray>("bytes")
                        assert(endpointId != null)
                        assert(bytes != null)
                        Nearby.getConnectionsClient((activity)!!).sendPayload(
                            (endpointId)!!,
                            Payload.fromBytes(
                                (bytes)!!,
                            ),
                        )
                        Log.d("nearby_connections", "sentPayload")
                        result.success(true)
                    }

                    "cancelPayload" -> {
                        val payloadId = call.argument<Any>("payloadId") as String?
                        assert(payloadId != null)
                        Nearby.getConnectionsClient((activity)!!)
                            .cancelPayload(payloadId!!.toLong())
                        Log.d("nearby_connections", "cancelPayload")
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            } catch (e: IllegalArgumentException) {
                // TODO: define argument error type
                result.error("", e.message, null)
            } catch (e: Exception) {
                // TODO: define event processing exception
                result.error("", e.message, null)
            }
        }
    }

    private val advertConnectionLifecycleCallback: ConnectionLifecycleCallback =
        object : ConnectionLifecycleCallback() {
            override fun onConnectionInitiated(
                endpointId: String,
                connectionInfo: ConnectionInfo,
            ) {
                Log.d("nearby_connections", "ad.onConnectionInitiated")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["endpointName"] = connectionInfo.endpointName
                args["authenticationToken"] = connectionInfo.authenticationToken
                args["isIncomingConnection"] = connectionInfo.isIncomingConnection
                channel.invokeMethod("ad.onConnectionInitiated", args)
            }

            override fun onConnectionResult(
                endpointId: String,
                connectionResolution: ConnectionResolution,
            ) {
                Log.d("nearby_connections", "ad.onConnectionResult")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                var statusCode = -1
                when (connectionResolution.status.statusCode) {
                    ConnectionsStatusCodes.STATUS_OK -> statusCode = 0
                    ConnectionsStatusCodes.STATUS_CONNECTION_REJECTED -> statusCode = 1
                    ConnectionsStatusCodes.STATUS_ERROR -> statusCode = 2
                    else -> {}
                }
                args["statusCode"] = statusCode
                channel.invokeMethod("ad.onConnectionResult", args)
            }

            override fun onDisconnected(endpointId: String) {
                Log.d("nearby_connections", "ad.onDisconnected")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                channel.invokeMethod("ad.onDisconnected", args)
            }
        }
    private val discoverConnectionLifecycleCallback: ConnectionLifecycleCallback =
        object : ConnectionLifecycleCallback() {
            override fun onConnectionInitiated(
                endpointId: String,
                connectionInfo: ConnectionInfo,
            ) {
                Log.d("nearby_connections", "dis.onConnectionInitiated")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["endpointName"] = connectionInfo.endpointName
                args["authenticationToken"] = connectionInfo.authenticationToken
                args["isIncomingConnection"] = connectionInfo.isIncomingConnection
                channel.invokeMethod("dis.onConnectionInitiated", args)
            }

            override fun onConnectionResult(
                endpointId: String,
                connectionResolution: ConnectionResolution,
            ) {
                Log.d("nearby_connections", "dis.onConnectionResult")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                var statusCode = -1
                when (connectionResolution.status.statusCode) {
                    ConnectionsStatusCodes.STATUS_OK -> statusCode = 0
                    ConnectionsStatusCodes.STATUS_CONNECTION_REJECTED -> statusCode = 1
                    ConnectionsStatusCodes.STATUS_ERROR -> statusCode = 2
                    else -> {}
                }
                args["statusCode"] = statusCode
                channel.invokeMethod("dis.onConnectionResult", args)
            }

            override fun onDisconnected(endpointId: String) {
                Log.d("nearby_connections", "dis.onDisconnected")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                channel.invokeMethod("dis.onDisconnected", args)
            }
        }
    private val payloadCallback: PayloadCallback =
        object : PayloadCallback() {
            override fun onPayloadReceived(
                endpointId: String,
                payload: Payload,
            ) {
                Log.d("nearby_connections", "onPayloadReceived")
                val args: MutableMap<String, Any?> = HashMap()
                args["endpointId"] = endpointId
                args["payloadId"] = payload.id
                args["type"] = payload.type
                if (payload.type == Payload.Type.BYTES) {
                    val bytes = payload.asBytes()
                    assert(bytes != null)
                    args["bytes"] = bytes
                } else if (payload.type == Payload.Type.FILE) {
                    args["uri"] = payload.asFile()!!.asUri().toString()
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                        // This is deprecated and only available on Android 10 and below.
                        args["filePath"] = payload.asFile()!!.asJavaFile()!!.absolutePath
                    }
                }
                channel.invokeMethod("onPayloadReceived", args)
            }

            override fun onPayloadTransferUpdate(
                endpointId: String,
                payloadTransferUpdate: PayloadTransferUpdate,
            ) {
                // required for files and streams
                Log.d("nearby_connections", "onPayloadTransferUpdate")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["payloadId"] = payloadTransferUpdate.payloadId
                args["status"] = payloadTransferUpdate.status
                args["bytesTransferred"] = payloadTransferUpdate.bytesTransferred
                args["totalBytes"] = payloadTransferUpdate.totalBytes
                channel.invokeMethod("onPayloadTransferUpdate", args)
            }
        }
    private val endpointDiscoveryCallback: EndpointDiscoveryCallback =
        object : EndpointDiscoveryCallback() {
            override fun onEndpointFound(
                endpointId: String,
                discoveredEndpointInfo: DiscoveredEndpointInfo,
            ) {
                Log.d("nearby_connections", "onEndpointFound")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                args["endpointName"] = discoveredEndpointInfo.endpointName
                args["serviceId"] = discoveredEndpointInfo.serviceId
                channel.invokeMethod("dis.onEndpointFound", args)
            }

            override fun onEndpointLost(endpointId: String) {
                Log.d("nearby_connections", "onEndpointLost")
                val args: MutableMap<String, Any> = HashMap()
                args["endpointId"] = endpointId
                channel.invokeMethod("dis.onEndpointLost", args)
            }
        }

    private fun getStrategy(strategyCode: Int): Strategy {
        return when (strategyCode) {
            0 -> Strategy.P2P_CLUSTER
            1 -> Strategy.P2P_STAR
            2 -> Strategy.P2P_POINT_TO_POINT
            else -> throw IllegalArgumentException()
        }
    }
}
