package com.courier.courier_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodChannel

enum class CourierFlutterChannel(val id: String) {
    SHARED("courier_flutter_shared"),
    CLIENT("courier_flutter_client"),
    EVENTS("courier_flutter_events")
}

fun CourierFlutterChannel.getChannel(binding: FlutterPluginBinding): MethodChannel {
    return MethodChannel(binding.binaryMessenger, id)
}