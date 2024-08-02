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
                
                let params = call.arguments as? Dictionary<String, Any>
                
                guard let client = try params?.toClient() else {
                    result(CourierFlutterError.missingParameter(value: "client").toFlutterError())
                    return
                }
                
                switch call.method {
                    
                case "client.brands.get_brand":
                    
                    guard let brandId = params?["brandId"] as? String else {
                        result(CourierFlutterError.missingParameter(value: "brandId").toFlutterError())
                        return
                    }
                    
                    let brand = try await client.brands.getBrand(brandId: brandId)
                    let json = try brand.toJson()
                    result(json)
                    
                case "client.tokens.put_user_token":
                    
                    guard let token = params?["token"] as? String else {
                        result(CourierFlutterError.missingParameter(value: "token").toFlutterError())
                        return
                    }
                    
                    guard let provider = params?["provider"] as? String else {
                        result(CourierFlutterError.missingParameter(value: "provider").toFlutterError())
                        return
                    }
                    
                    let deviceParams = params?["device"] as? [String: Any]
                    let device = try deviceParams?.toCourierDevice()
                    
                    try await client.tokens.putUserToken(token: token, provider: provider)
                    result(nil)
                    
                case "client.tokens.delete_user_token":
                    
                    guard let token = params?["token"] as? String else {
                        result(CourierFlutterError.missingParameter(value: "token").toFlutterError())
                        return
                    }
                    
                    try await client.tokens.deleteUserToken(token: token)
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
