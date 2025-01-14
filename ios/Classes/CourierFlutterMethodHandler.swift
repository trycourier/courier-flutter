//
//  CourierFlutterMethodHandler.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/16/24.
//

import Courier_iOS

public class CourierFlutterMethodHandler: NSObject {
    
    override init() {
        super.init()
        
        // Set the flutter ios user agent
        // This ensures all the requests are tagged with this agent
        Courier.agent = CourierAgent.flutterIOS("4.0.0")
        
    }
    
}
