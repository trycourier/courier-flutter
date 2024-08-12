package com.courier.courier_flutter

import com.courier.android.client.CourierClient
import com.courier.android.models.CourierDevice
import com.google.gson.GsonBuilder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

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

internal fun HashMap<*, *>.toClient(): CourierClient {

    val options = this["options"] as? HashMap<*, *> ?: throw MissingParameter("options")
    val userId = options["userId"] as? String ?: throw MissingParameter("userId")
    val showLogs = options["showLogs"] as? Boolean ?: throw MissingParameter("showLogs")

    val jwt = options["jwt"] as? String
    val clientKey = options["clientKey"] as? String
    val connectionId = options["connectionId"] as? String
    val tenantId = options["tenantId"] as? String

    return CourierClient(
        jwt = jwt,
        clientKey = clientKey,
        userId = userId,
        connectionId = connectionId,
        tenantId = tenantId,
        showLogs = showLogs
    )

}

// Stringify

internal fun Any.toJson(): String {
    return GsonBuilder().setPrettyPrinting().create().toJson(this)
}

// Threaded Callback

internal fun post(block: suspend CoroutineScope.() -> Unit) {
    CoroutineScope(Dispatchers.Main).launch {
        block()
    }
}

// Handle Params

internal inline fun <reified T> Map<*, *>.extract(key: String): T {
    return this[key] as? T ?: throw MissingParameter(key)
}