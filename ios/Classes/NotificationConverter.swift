//
//  MessageReducer.swift
//  courier_flutter
//
//  Created by Michael Miller on 10/13/22.
//

import Foundation

extension UNNotificationContent {
    
    var pushNotification: [AnyHashable : Any?] {
        get {
            
            // Initial payload
            var payload: [AnyHashable : Any?] = [
                "title": title,
                "subtitle": nil,
                "body": body,
                "badge": badge,
                "sound": nil
            ]
            
            // Do not add subtitle if it's empty
            if (!subtitle.isEmpty) {
                payload["subtitle"] = subtitle
            }
            
            // Add sound as a string
            if let aps = userInfo["aps"] as? [AnyHashable : Any?], let sound = aps["sound"] {
                payload["sound"] = sound
            }
            
            // Merge the payload data
            // This appends all custom attributes
            var data = userInfo
            data.removeValue(forKey: "aps")
            data.forEach { payload[$0] = $1 }
            
            // Add the raw data
            payload["raw"] = userInfo
            
            return payload
            
        }
    }
    
}
