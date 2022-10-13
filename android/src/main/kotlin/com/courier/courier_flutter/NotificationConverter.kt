package com.courier.courier_flutter

import com.google.firebase.messaging.RemoteMessage

val RemoteMessage.pushNotification: Map<String, Any?>
    get() {

        val rawData = data.toMutableMap()
        val payload = mutableMapOf<String, Any?>()

        // Add existing values to base map
        // then remove the unneeded keys
        val baseKeys = listOf("title", "subtitle", "body", "badge", "sound")
        baseKeys.forEach { key ->
            payload[key] = data[key]
            rawData.remove(key)
        }

        // Add extras
        for ((key, value) in rawData) {
            payload[key] = value
        }

        // Add the raw data
        payload["raw"] = data

        return payload

    }