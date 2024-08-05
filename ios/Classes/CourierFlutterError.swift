//
//  CourierFlutterError.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/2/24.
//

import Flutter

internal struct MissingParameter: Error {
    
    let value: String
    
    func toFlutter() -> FlutterError {
        return FlutterError(
            code: CourierPlugin.COURIER_ERROR_TAG,
            message: "Missing parameter: \(value)",
            details: nil
        )
    }
    
}
