package com.courier.courier_flutter

import com.google.firebase.messaging.RemoteMessage

interface CourierFlutterPushNotificationListener {
    fun postPushNotificationDelivered(message: RemoteMessage)
    fun postPushNotificationClicked(message: RemoteMessage)
}