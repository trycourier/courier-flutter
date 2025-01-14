//
//  Utils.swift
//  courier_flutter
//
//  Created by Michael Miller on 11/2/23.
//

import Foundation
import Courier_iOS

extension UNAuthorizationStatus {
    
    var name: String {
        switch (self) {
        case .notDetermined: return "notDetermined"
        case .denied:        return "denied"
        case .authorized:    return "authorized"
        case .provisional:   return "provisional"
        case .ephemeral:     return "ephemeral"
        @unknown default:    return "unknown"
        }
    }
    
}

internal extension Encodable {
    
    func toJson() throws -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? nil
    }
    
}

internal extension String {
    
    func toRowAnimation() -> UITableView.RowAnimation {
        
        switch self.lowercased() {
            case "fade": return .fade
            case "right": return .right
            case "left": return .left
            case "top": return .top
            case "bottom": return .bottom
            case "none": return .none
            case "middle": return .middle
            case "automatic":
                if #available(iOS 11.0, *) {
                    return .automatic
                } else {
                    return .fade
                }
            default: return .fade
        }
        
    }
    
    func toSeparatorStyle() -> UITableViewCell.SeparatorStyle {
        
        switch self.lowercased() {
            case "none": return .none
            case "singleLine": return .singleLine
            case "singleLineEtched": return .singleLineEtched
            default: return .singleLine
        }
        
    }
    
    func toSelectionStyle() -> UITableViewCell.SelectionStyle? {
        
        switch self.lowercased() {
            case "none": return .none
            case "blue": return .blue
            case "gray": return .gray
            case "default": return .default
            default: return .default
        }
        
    }
    
    func toColor() -> UIColor? {
        
        var hexSanitized = trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        guard hexSanitized.count == 6 else {
            return nil
        }

        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
        
    }
    
}

internal extension Dictionary<String, Any> {
    
    func toClient() throws -> CourierClient? {
        
        guard let options = self["options"] as? [String: Any] else {
            throw CourierFlutterError.missingParameter(value: "options")
        }
        
        guard let userId = options["userId"] as? String else {
            throw CourierFlutterError.missingParameter(value: "userId")
        }
        
        guard let showLogs = options["showLogs"] as? Bool else {
            throw CourierFlutterError.missingParameter(value: "showLogs")
        }
        
        let jwt = options["jwt"] as? String
        let clientKey = options["clientKey"] as? String
        let connectionId = options["connectionId"] as? String
        let tenantId = options["tenantId"] as? String
        
        return CourierClient(
            jwt: jwt,
            clientKey: clientKey,
            userId: userId,
            connectionId: connectionId,
            tenantId: tenantId,
            showLogs: showLogs
        )
        
    }
    
    func extract<T>(_ key: String) throws -> T {
        guard let value = self[key] as? T else {
            throw CourierFlutterError.missingParameter(value: key)
        }
        return value
    }
    
}

internal extension Error {
    
    func toFlutterError() -> FlutterError {
        
//        let code: String
        let message: String
        
        switch self {
        case let courierError as CourierFlutterError:
            switch courierError {
            case .missingParameter(let value):
                message = "Missing Parameter: \(value)"
            case .invalidParameter(let value):
                message = "Invalid Parameter: \(value)"
            case .unknown:
                message = "An unknown error occurred."
            }
        default:
            message = String(describing: self)
        }
        
        return FlutterError(
            code: "COURIER_IOS_SDK_ERROR",
            message: message,
            details: nil
        )
        
    }
}

internal extension NSDictionary {
    
    @objc func toJson() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error converting NSDictionary to JSON: \(error)")
            return nil
        }
    }
    
}

internal extension UIApplication {
    
    func makeChannel(id: String) -> FlutterMethodChannel? {

        // Get window
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }

        // Get messenger
        let flutterViewController = window.rootViewController as? FlutterViewController
        let binaryMessenger = flutterViewController as? FlutterBinaryMessenger
        guard let messenger = binaryMessenger else {
            return nil
        }

        // Create the channel
        return FlutterMethodChannel(name: id, binaryMessenger: messenger)
        
    }
    
}

internal extension Dictionary where Key == String, Value == Any {
    
    func toCourierDevice() throws -> CourierDevice? {
        
        let appId = self["app_id"] as? String
        let adId = self["ad_id"] as? String
        let deviceId = self["device_id"] as? String
        let platform = self["platform"] as? String
        let manufacturer = self["manufacturer"] as? String
        let model = self["model"] as? String
        
        return CourierDevice(
            appId: appId,
            adId: adId,
            deviceId: deviceId,
            platform: platform,
            manufacturer: manufacturer,
            model: model
        )
        
    }
    
}
