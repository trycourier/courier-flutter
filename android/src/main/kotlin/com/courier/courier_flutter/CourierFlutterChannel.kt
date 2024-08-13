package com.courier.courier_flutter

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

internal enum class CourierFlutterChannel(val id: String) {
    SHARED("courier_flutter_shared"),
    CLIENT("courier_flutter_client"),
    EVENTS("courier_flutter_events"),
    SYSTEM("courier_flutter_system"),
}

internal fun CourierFlutterChannel.getChannel(messenger: BinaryMessenger) = MethodChannel(messenger, id)

internal fun CourierFlutterChannel.invokeMethod(messenger: BinaryMessenger, method: String, arguments: Any?) {
    CoroutineScope(Dispatchers.Main).launch {
        getChannel(messenger).invokeMethod(method, arguments)
    }
}