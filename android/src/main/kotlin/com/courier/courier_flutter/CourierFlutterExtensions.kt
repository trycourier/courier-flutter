package com.courier.courier_flutter

import android.content.Intent
import com.courier.android.utils.pushNotification
import com.courier.android.utils.trackPushNotificationClick
import com.google.firebase.messaging.RemoteMessage
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

fun FlutterEngine.setupCourierMethodChannel(onRequestNotificationPermission: ((String) -> Unit)? = null, onGetNotificationPermissionStatus: ((String) -> Unit)? = null, onGetClickedNotification: (() -> Unit)? = null): MethodChannel {

    // Create the method channel
    val channel = MethodChannel(dartExecutor.binaryMessenger, CourierFlutterPlugin.EVENTS_CHANNEL)

    // Handle the calls
    channel.setMethodCallHandler { call, result ->

        when (call.method) {

            "requestNotificationPermission" -> {

                // TODO: Not supported yet due to AppCompat issues
                val value = "unknown"
                onRequestNotificationPermission?.invoke(value)
                result.success(value)

            }

            "getNotificationPermissionStatus" -> {

                // TODO: Not supported yet due to AppCompat issues
                val value = "unknown"
                onGetNotificationPermissionStatus?.invoke(value)
                result.success(value)

            }

            "getClickedNotification" -> {

                onGetClickedNotification?.invoke()
                result.success(null)

            }

            else -> {
                result.notImplemented()
            }

        }

    }

    // Return the channel
    return channel

}

fun MethodChannel.deliverCourierPushNotification(message: RemoteMessage) {
    invokeMethod("pushNotificationDelivered", message.pushNotification)
}

fun MethodChannel.clickCourierPushNotification(message: RemoteMessage) {
    invokeMethod("pushNotificationClicked", message.pushNotification)
}

fun Intent.getAndTrackRemoteMessage(): RemoteMessage? {

    var clickedMessage: RemoteMessage? = null

    // Try and track the clicked message
    // Will return a message if the message was able to be tracked
    trackPushNotificationClick { message ->
        clickedMessage = message
    }

    return clickedMessage

}