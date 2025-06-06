package com.courier.courier_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.courier.android.Courier
import com.courier.android.models.CourierTrackingEvent
import com.courier.android.modules.isPushPermissionGranted
import com.courier.android.modules.requestNotificationPermission
import com.courier.android.utils.onPushNotificationEvent
import com.courier.android.utils.pushNotification
import com.courier.android.utils.trackPushNotificationClick
import com.google.firebase.messaging.RemoteMessage
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

internal class CourierSystemEventHandler : CourierFlutterPushNotificationListener {

    private var systemChannel: MethodChannel? = null
    private var eventsChannel: MethodChannel? = null

    fun configure(flutterEngine: FlutterEngine, activity: Activity) {

        // Create the method channel
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        systemChannel = CourierFlutterChannel.SYSTEM.getChannel(messenger)
        eventsChannel = CourierFlutterChannel.EVENTS.getChannel(messenger)

        // Handle the calls
        systemChannel?.setMethodCallHandler { call, result ->

            when (call.method) {

                "notifications.request_permission" -> {

                    Courier.shared.requestNotificationPermission(activity)
                    result.success("unknown")

                }

                "notifications.get_permission_status" -> {

                    val isGranted = Courier.shared.isPushPermissionGranted(activity)
                    result.success(if (isGranted) "authorized" else "denied")

                }

                "notifications.get_clicked_notification" -> {

                    activity.intent.getAndTrackRemoteMessage()?.let { message ->
                        postPushNotificationClicked(message)
                    }

                    result.success(null)

                }

                else -> {

                    result.notImplemented()

                }

            }

        }

    }

    fun attach(context: Context, intent: Intent) {

        // Initialize the SDK
        Courier.initialize(context)

        // See if there is a pending click event
        checkIntentForPushNotificationClick(intent)

        // Handle delivered messages on the main thread
        Courier.shared.onPushNotificationEvent { event ->
            if (event.trackingEvent == CourierTrackingEvent.DELIVERED) {
                postPushNotificationDelivered(event.remoteMessage)
            }
        }

    }

    private fun checkIntentForPushNotificationClick(intent: Intent?) {
        intent?.trackPushNotificationClick { message ->
            postPushNotificationClicked(message)
        }
    }

    fun newIntent(intent: Intent) {
        checkIntentForPushNotificationClick(intent)
    }

    fun detach() {
        eventsChannel?.setMethodCallHandler(null)
    }

    override fun postPushNotificationDelivered(message: RemoteMessage) {
        eventsChannel?.invokeMethod("push.delivered", message.pushNotification)
    }

    override fun postPushNotificationClicked(message: RemoteMessage) {
        eventsChannel?.invokeMethod("push.clicked", message.pushNotification)
    }

}