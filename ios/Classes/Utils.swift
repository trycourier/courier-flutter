//
//  Utils.swift
//  courier_flutter
//
//  Created by Michael Miller on 11/2/23.
//

import Foundation
import Courier_iOS

extension UIWindow {
    
    var messanger: FlutterBinaryMessenger? {
        get {
            let flutterViewController = rootViewController as? FlutterViewController
            let binaryMessenger = flutterViewController as? FlutterBinaryMessenger
            return binaryMessenger
        }
    }
    
}

extension FlutterBinaryMessenger {
    
    func channel(id: String) -> FlutterMethodChannel {
        return FlutterMethodChannel(name: id, binaryMessenger: self)
    }
    
}

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

internal extension [String: Any?] {
    
    func clean() -> NSMutableDictionary {
        
        let mutableDictionary = NSMutableDictionary()
        for (key, value) in self {
            if let unwrappedValue = value {
                mutableDictionary[key] = unwrappedValue
            }
        }
        
        return mutableDictionary
        
    }
    
}

internal extension CourierBrand {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "settings": settings?.toDictionary(),
        ]

        return dictionary.clean()
        
    }
    
}

internal extension CourierBrandSettings {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "colors": colors?.toDictionary(),
            "inapp": inapp?.toDictionary(),
        ]

        return dictionary.clean()
        
    }
    
}

internal extension CourierBrandInApp {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "showCourierFooter": showCourierFooter,
        ]

        return dictionary.clean()
        
    }
    
}

internal extension CourierBrandColors {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "primary": primary,
        ]

        return dictionary.clean()
        
    }
    
}

internal extension CourierUserPreferences {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "items": items.map { $0.toDictionary() },
            "paging": paging.toDictionary(),
        ]

        return dictionary.clean()
        
    }
    
}

internal extension CourierUserPreferencesTopic {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "defaultStatus": defaultStatus.rawValue,
            "hasCustomRouting": hasCustomRouting,
            "customRouting": customRouting.map { $0.rawValue },
            "status": status.rawValue,
            "topicId": topicId,
            "topicName": topicName,
            "sectionName": sectionName,
            "sectionId": sectionId,
        ]

        return dictionary.clean()
        
    }
    
}

internal extension CourierUserPreferencesPaging {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "cursor": cursor,
            "more": more,
        ]

        return dictionary.clean()
        
    }
    
}

internal extension InboxMessage {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "messageId": messageId,
            "title": title,
            "body": body,
            "preview": preview,
            "created": created,
            "actions": actions?.map { $0.toDictionary() },
            "data": data,
            "read": read,
            "opened": opened,
            "archived": archived
        ]
        
        return dictionary.clean()
        
    }
    
}

internal extension InboxAction {
    
    @objc func toDictionary() -> NSDictionary {
        
        let dictionary: [String: Any?] = [
            "content": content,
            "href": href,
            "data": data
        ]

        return dictionary.clean()
        
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
            throw MissingParameter(value: "options")
        }
        
        guard let userId = options["userId"] as? String else {
            throw MissingParameter(value: "userId")
        }
        
        guard let showLogs = options["showLogs"] as? Bool else {
            throw MissingParameter(value: "showLogs")
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
            throw MissingParameter(value: key)
        }
        return value
    }
    
}

extension Error {
    
    func toFlutterError() -> FlutterError {
        return FlutterError.init(
            code: CourierPlugin.COURIER_ERROR_TAG,
            message: String(describing: self),
            details: nil
        )
    }
    
}
