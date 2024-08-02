package com.courier.courier_flutter

import com.courier.android.models.CourierException

class CourierFlutterException(message: String): Exception(message) {
    companion object {
        val missingParameter = CourierException("Missing Parameter")
    }
}