package com.courier.courier_flutter

import com.courier.android.client.CourierClient
import com.google.gson.GsonBuilder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

internal fun HashMap<*, *>.toClient(): CourierClient? {

    val options = this["options"] as? HashMap<*, *> ?: return null

    val userId = options["userId"] as? String ?: return null
    val showLogs = options["showLogs"] as? Boolean ?: return null

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

internal fun Any.toJson(): String {
    return GsonBuilder().setPrettyPrinting().create().toJson(this)
}

internal fun post(block: suspend CoroutineScope.() -> Unit) {
    CoroutineScope(Dispatchers.Main).launch {
        block()
    }
}