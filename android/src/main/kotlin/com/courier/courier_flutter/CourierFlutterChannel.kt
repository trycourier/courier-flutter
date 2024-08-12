package com.courier.courier_flutter

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

enum class CourierFlutterChannel(val id: String) {
    SHARED("courier_flutter_shared"),
    CLIENT("courier_flutter_client"),
    EVENTS("courier_flutter_events"),
    SYSTEM("courier_flutter_system"),
}

fun CourierFlutterChannel.getChannel(messenger: BinaryMessenger): MethodChannel {
    return MethodChannel(messenger, id)
}