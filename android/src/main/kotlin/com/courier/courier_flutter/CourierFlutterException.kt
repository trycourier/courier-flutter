package com.courier.courier_flutter

internal class MissingParameter(value: String) : Exception("Missing parameter: $value")
internal class InvalidParameter(value: String) : Exception("Invalid parameter: $value")