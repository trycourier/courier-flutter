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
            "status": status,
            "topicId": topicId,
            "topicName": topicName,
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
