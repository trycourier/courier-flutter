package com.courier.courier_flutter

import com.courier.android.models.CourierDevice
import com.courier.courier_flutter.CourierPlugin.Companion.TAG
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

internal class CourierClientMethodHandler : MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = post {

        try {

            val params = call.arguments as? HashMap<*, *>

            val client = params?.toClient() ?: throw MissingParameter("client")

            when (call.method) {

                "client.brands.get_brand" -> {

                    val brandId = params["brandId"] as? String ?: throw MissingParameter("brandId")

                    val brand = client.brands.getBrand(brandId)
                    val json = brand.toJson()
                    result.success(json)

                }

                "client.tokens.put_user_token" -> {

                    val token = params["token"] as? String ?: throw MissingParameter("token")
                    val provider = params["provider"] as? String ?: throw MissingParameter("provider")

                    val deviceParams = params["device"] as? Map<*, *>
                    val device = deviceParams?.toCourierDevice()

                    client.tokens.putUserToken(
                        token = token,
                        provider = provider,
                        device = device ?: CourierDevice.current,
                    )

                    result.success(null)

                }

                "client.tokens.delete_user_token" -> {

                    val token = params["token"] as? String ?: throw MissingParameter("token")

                    client.tokens.deleteUserToken(
                        token = token,
                    )

                    result.success(null)

                }

                else -> {
                    result.notImplemented()
                }

            }

        } catch (e: Exception) {

            result.error(TAG, e.message, e)

        }

    }

}

internal fun Map<*, *>.toCourierDevice(): CourierDevice {
    val appId = this["app_id"] as? String
    val adId = this["ad_id"] as? String
    val deviceId = this["device_id"] as? String
    val platform = this["platform"] as? String
    val manufacturer = this["manufacturer"] as? String
    val model = this["model"] as? String
    return CourierDevice(
        app_id = appId,
        ad_id = adId,
        device_id = deviceId,
        platform = platform,
        manufacturer = manufacturer,
        model = model
    )
}