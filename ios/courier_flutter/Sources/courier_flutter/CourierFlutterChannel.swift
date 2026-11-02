//
//  CourierFlutterChannel.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/8/24.
//

import Flutter

internal enum CourierFlutterChannel: String {
    case shared = "courier_flutter_shared"
    case client = "courier_flutter_client"
    case events = "courier_flutter_events"
}

internal extension CourierFlutterChannel {
    
    var channel: FlutterMethodChannel? {
        get {
            return UIApplication.shared.makeChannel(id: self.rawValue)
        }
    }
    
}
