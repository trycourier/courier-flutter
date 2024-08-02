//
//  CourierFlutterError.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/2/24.
//

import Foundation

internal enum CourierFlutterError: Error {
    
    case missingParameter(value: String)
    
    func toFlutterError() -> FlutterError {
        let message: String
        switch self {
        case .missingParameter(let value):
            message = "Missing parameter: \(value)"
            return FlutterError(
                code: CourierPlugin.COURIER_ERROR_TAG,
                message: message,
                details: nil
            )
        }
    }
    
}
