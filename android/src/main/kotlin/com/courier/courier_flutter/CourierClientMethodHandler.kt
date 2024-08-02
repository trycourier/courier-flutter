package com.courier.courier_flutter

import com.courier.courier_flutter.CourierPlugin.Companion.TAG
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

internal class CourierClientMethodHandler : MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = post {

        try {

            val params = call.arguments as? HashMap<*, *>

            when (call.method) {

                "getBrand" -> {

                    val client = params?.toClient()
                    val brandId = params?.get("brandId") as? String

                    if (client == null || brandId == null) {
                        val error = CourierFlutterException.missingParameter
                        result.error(TAG, error.message, error)
                        return@post
                    }

                    val brand = client.brands.getBrand(brandId)
                    result.success(brand.toJson())

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