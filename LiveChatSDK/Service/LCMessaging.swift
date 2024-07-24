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
            let contentRaw = dataDict["content"] as! [String:Any]
            let fromRaw = dataDict["sender"] as! [String: Any]
            let lcMessage = LCMessage(
                id: dataDict["id"] as! Int,
                content: LCParseUtil.contentFrom(contentRaw: contentRaw),
                from: LCSender(
                    id: fromRaw["id"] as! String,
                    name: fromRaw["name"] as! String
                ),
                timeCreated: fromRaw["created_at"] as! String
            )
            LiveChatSDK.observingMessage(lcMesasge: lcMessage)
        } catch{
            LCLog.logI(message: "Error parse data \(error)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
