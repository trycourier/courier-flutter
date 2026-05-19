package com.courier.courier_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import com.courier.android.Courier
import com.courier.android.models.CourierTrackingEvent.CLICKED
import com.courier.android.models.CourierTrackingEvent.DELIVERED
import com.courier.android.modules.isPushPermissionGranted
import com.courier.android.modules.requestNotificationPermission
import com.courier.android.utils.trackPushNotificationClick
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

internal class CourierSystemEventHandler : CourierFlutterPushNotificationListener {

    private var systemChannel: MethodChannel? = null
    private var eventsChannel: MethodChannel? = null

    fun configure(flutterEngine: FlutterEngine, activity: Activity) {

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        systemChannel = CourierFlutterChannel.SYSTEM.getChannel(messenger)
        eventsChannel = CourierFlutterChannel.EVENTS.getChannel(messenger)

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

                    activity.intent.getAndTrackPushData()?.let { data ->
                        postPushNotificationClicked(data)
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

        Courier.initialize(context)

        checkIntentForPushNotificationClick(intent)

        Courier.onPushNotificationEvent { event ->
            when (event.trackingEvent) {
                CLICKED -> postPushNotificationClicked(event.data)
                DELIVERED -> postPushNotificationDelivered(event.data)
                else -> Log.w("CourierSystemEventHandler", "Unknown tracking event: ${event.trackingEvent}")
            }
        }

    }

    private fun checkIntentForPushNotificationClick(intent: Intent?) {
        intent?.trackPushNotificationClick { message ->
            postPushNotificationClicked(message.data)
        }
    }

    fun newIntent(intent: Intent) {
        checkIntentForPushNotificationClick(intent)
    }

    fun detach() {
        eventsChannel?.setMethodCallHandler(null)
    }

    private fun buildPushPayload(data: Map<String, String>): Map<String, Any?> {
        val rawData = data.toMutableMap()
        val payload = mutableMapOf<String, Any?>()
        val baseKeys = listOf("title", "subtitle", "body", "badge", "sound")
        baseKeys.forEach { key ->
            payload[key] = data[key]
            rawData.remove(key)
        }
        for ((key, value) in rawData) {
            payload[key] = value
        }
        payload["raw"] = data
        return payload
    }

    override fun postPushNotificationDelivered(data: Map<String, String>) {
        eventsChannel?.invokeMethod("push.delivered", buildPushPayload(data))
    }

    override fun postPushNotificationClicked(data: Map<String, String>) {
        eventsChannel?.invokeMethod("push.clicked", buildPushPayload(data))
    }

}