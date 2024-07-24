//
//  LCMessaging.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 12/07/2024.
//

import Foundation
import UserNotifications
import Firebase
import UIKit

open class LCMessaging: NSObject, UNUserNotificationCenterDelegate {
    
    public func configure(){
        FirebaseApp.configure()
    }
    
    open func application(_ application: UIApplication,
                          didReceiveRemoteNotification data: [AnyHashable: Any],
                          fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LCLog.logI(message: "Framework received data message: \(data)")
        do {
            var dataDict: [String:Any] = [:]
            for (key, value) in data {
                if let stringKey = key as? String {
                    if let valueDict = value as? [String: Any] {
                        dataDict[stringKey] = valueDict
                        LCLog.logI(message: "valueDict: \(valueDict)")
                    } else if let valueArray = value as? [Any] {
                        dataDict[stringKey] = valueArray
                        LCLog.logI(message: "valueNSString: \(valueArray)")
                    } else if let valueString = value as? String {
                        dataDict[stringKey] = valueString
                        LCLog.logI(message: "valueString: \(valueString)")
                    } else if let valueInt = value as? Int {
                        dataDict[stringKey] = valueInt
                        LCLog.logI(message: "valueInt: \(valueInt)")
                    } else if let valueBool = value as? Bool {
                        dataDict[stringKey] = valueBool
                        LCLog.logI(message: "valueBool: \(valueBool)")
                    } else if let valueDouble = value as? Double {
                        dataDict[stringKey] = valueDouble
                        LCLog.logI(message: "valueDouble: \(valueDouble)")
                    } else if let valueNSString = value as? NSString{
                        dataDict[stringKey] = valueNSString
                        LCLog.logI(message: "valueNSString: \(valueNSString)")
                    } else {
                        // Handle other types if needed
                        LCLog.logI(message: "Unsupported value type for key: \(stringKey)")
                    }
                }
            }
            let contentRaw = dataDict["content"] as! String
            let contentDict = convertToDictionary(text: contentRaw)
            let fromRaw = dataDict["sender"] as! String
            let fromDict = convertToDictionary(text: fromRaw)
            let lcMessage = LCMessage(
                id: dataDict["id"] as! Int,
                content: LCParseUtil.contentFrom(contentRaw: contentDict),
                from: LCSender(
                    id: fromDict["id"] as! String,
                    name: fromDict["name"] as! String
                ),
                timeCreated: data["created_at"] as! String
            )
            LiveChatSDK.observingMessage(lcMesasge: lcMessage)
        } catch{
            LCLog.logI(message: "Error parse data \(error)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func convertToDictionary(text: String) -> [String: Any] {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return [:]
    }

    
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
