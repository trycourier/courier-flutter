//
//  CourierFlutterError.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/2/24.
//

import Flutter

internal enum CourierFlutterError: Error {
    case missingParameter(value: String)
    case invalidParameter(value: String)
    case unknown
}
