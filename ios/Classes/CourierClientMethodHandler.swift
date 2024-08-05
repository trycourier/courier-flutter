//
//  CourierClientMethodHandler.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/2/24.
//

import Foundation
import Courier_iOS

internal class CourierClientMethodHandler: NSObject, FlutterPlugin {
    
    static func register(with registrar: any FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CourierPlugin.Channels.client.rawValue, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(CourierClientMethodHandler(), channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        Task {
            
            do {
                
                guard let params = call.arguments as? Dictionary<String, Any>, let client = try params.toClient() else {
                    throw MissingParameter(value: "client")
                }
                
                switch call.method {
                    
                    // MARK: Brand
                    
                case "client.brands.get_brand":
                    
                    let (brandId): (String) = (
                        try params.extract("brandId")
                    )
                    
                    let brand = try await client.brands.getBrand(
                        brandId: brandId
                    )
                    
                    let json = try brand.toJson()
                    
                    result(json)
                    
                    // MARK: Token Management
                    
                case "client.tokens.put_user_token":
                    
                    let (token, provider): (String, String) = (
                        try params.extract("token"),
                        try params.extract("provider")
                    )
                    
                    let deviceParams = params["device"] as? [String: Any]
                    let device = try deviceParams?.toCourierDevice()
                    
                    try await client.tokens.putUserToken(
                        token: token,
                        provider: provider
                    )
                    
                    result(nil)
                    
                case "client.tokens.delete_user_token":
                    
                    let (token, provider): (String, String) = (
                        try params.extract("token"),
                        try params.extract("provider")
                    )
                    
                    try await client.tokens.deleteUserToken(
                        token: token
                    )
                    
                    result(nil)
                    
                    // MARK: Tracking
                    
                case "client.tracking.post_tracking_url":
                    
                    let (url, event): (String, String) = (
                        try params.extract("url"),
                        try params.extract("event")
                    )
                    
                    guard let trackingEvent = CourierTrackingEvent(rawValue: event) else {
                        throw MissingParameter(value: "tracking_event")
                    }
                    
                    try await client.tracking.postTrackingUrl(
                        url: url,
                        event: trackingEvent
                    )
                    
                    result(nil)
                    
                default:
                    
                    result(FlutterMethodNotImplemented)
                    
                }
                
            } catch {
                
                result(error.toFlutterError())
                
            }
            
        }
          
    }
    
}

extension Dictionary where Key == String, Value == Any {
    
    func toCourierDevice() throws -> CourierDevice? {
        
        let appId = self["app_id"] as? String
        let adId = self["ad_id"] as? String
        let deviceId = self["device_id"] as? String
        let platform = self["platform"] as? String
        let manufacturer = self["manufacturer"] as? String
        let model = self["model"] as? String
        
        return CourierDevice(
            app_id: appId,
            ad_id: adId,
            device_id: deviceId,
            platform: platform,
            manufacturer: manufacturer,
            model: model
        )
        
    }
    
}
