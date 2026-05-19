package com.courier.courier_flutter

import android.content.Intent
import com.courier.android.client.CourierClient
import com.courier.android.models.CourierDevice
import com.courier.android.utils.trackPushNotificationClick
import com.google.gson.GsonBuilder

// Push Data

internal fun Intent.getAndTrackPushData(): Map<String, String>? {

    var clickedData: Map<String, String>? = null

    trackPushNotificationClick { message ->
        clickedData = message.data
    }

    return clickedData

}

// Courier Device

internal fun Map<*, *>.toCourierDevice(): CourierDevice {
    val appId = this["app_id"] as? String
    val adId = this["ad_id"] as? String
    val deviceId = this["device_id"] as? String
    val platform = this["platform"] as? String
    val manufacturer = this["manufacturer"] as? String
    val model = this["model"] as? String
    return CourierDevice(
        appId = appId,
        adId = adId,
        deviceId = deviceId,
        platform = platform,
        manufacturer = manufacturer,
        model = model
    )
}

// Create Client

internal fun String?.toApiUrls(): CourierClient.ApiUrls {
    return when (this) {
        "eu" -> CourierClient.ApiUrls.eu()
        else -> CourierClient.ApiUrls()
    }
}

internal fun Map<*, *>.toBackendApiUrls(): CourierClient.ApiUrls {
    return CourierClient.ApiUrls(
        rest = this["rest"] as? String ?: CourierClient.ApiUrls().rest,
        graphql = this["graphql"] as? String ?: CourierClient.ApiUrls().graphql,
        inboxGraphql = this["inboxGraphql"] as? String ?: CourierClient.ApiUrls().inboxGraphql,
        inboxWebSocket = this["inboxWebSocket"] as? String ?: CourierClient.ApiUrls().inboxWebSocket,
    )
}

internal fun Map<*, *>.resolveApiUrls(): CourierClient.ApiUrls {
    val backendUrls = this["backendUrls"] as? Map<*, *>
    if (backendUrls != null) return backendUrls.toBackendApiUrls()
    return (this["apiUrls"] as? String).toApiUrls()
}

internal fun HashMap<*, *>.toClient(): CourierClient {

    val options = this["options"] as? HashMap<*, *> ?: throw MissingParameter("options")
    val userId = options["userId"] as? String ?: throw MissingParameter("userId")
    val showLogs = options["showLogs"] as? Boolean ?: throw MissingParameter("showLogs")

    val jwt = options["jwt"] as? String
    val clientKey = options["clientKey"] as? String
    val connectionId = options["connectionId"] as? String
    val tenantId = options["tenantId"] as? String
    val apiUrls = options.resolveApiUrls()

    return CourierClient(
        jwt = jwt,
        clientKey = clientKey,
        userId = userId,
        connectionId = connectionId,
        tenantId = tenantId,
        apiUrls = apiUrls,
        showLogs = showLogs
    )

}

// Stringify

internal fun Any.toJson(): String {
    return GsonBuilder().setPrettyPrinting().create().toJson(this)
}

// Handle Params

internal inline fun <reified T> Map<*, *>.extract(key: String): T {
    return this[key] as? T ?: throw MissingParameter(key)
}