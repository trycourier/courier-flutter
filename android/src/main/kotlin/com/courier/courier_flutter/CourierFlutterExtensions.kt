package com.courier.courier_flutter

import android.content.Intent
import com.courier.android.models.*
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

internal fun InboxMessage.toMap(): Map<String, Any?> {
    return mapOf(
        "messageId" to messageId,
        "title" to title,
        "body" to body,
        "preview" to preview,
        "created" to created,
        "actions" to actions?.map { it.toMap() },
        "data" to data,
        "read" to isRead,
        "isOpened" to isOpened,
        "isArchived" to isArchived,
    )
}

internal fun InboxAction.toMap(): Map<String, Any?> {
    return mapOf(
        "content" to content,
        "href" to href,
        "data" to data
    )
}

internal fun CourierUserPreferences.toMap(): Map<String, Any?> {
    return mapOf(
        "items" to items.map { it.toMap() },
        "paging" to paging.toMap(),
    )
}

internal fun CourierPreferenceTopic.toMap(): Map<String, Any?> {
    return mapOf(
        "defaultStatus" to defaultStatus.value,
        "hasCustomRouting" to hasCustomRouting,
        "status" to status.value,
        "topicId" to topicId,
        "topicName" to topicName,
        "customRouting" to customRouting.map { it.value }
    )
}

internal fun Paging.toMap(): Map<String, Any?>{
    return mapOf(
        "cursor" to cursor,
        "more" to more,
    )
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