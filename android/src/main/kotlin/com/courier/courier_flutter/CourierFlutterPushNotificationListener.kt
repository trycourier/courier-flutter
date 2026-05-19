package com.courier.courier_flutter

interface CourierFlutterPushNotificationListener {
    fun postPushNotificationDelivered(data: Map<String, String>)
    fun postPushNotificationClicked(data: Map<String, String>)
}

