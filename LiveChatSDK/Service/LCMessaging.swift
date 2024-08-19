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
        var dataDict: [String:Any] = [:]
        for (key, value) in data {
            if let stringKey = key as? String {
                if let valueDict = value as? [String: Any] {
                    dataDict[stringKey] = valueDict
                } else if let valueArray = value as? [Any] {
                    dataDict[stringKey] = valueArray
                } else if let valueString = value as? String {
                    dataDict[stringKey] = valueString
                } else if let valueInt = value as? Int {
                    dataDict[stringKey] = valueInt
                } else if let valueBool = value as? Bool {
                    dataDict[stringKey] = valueBool
                } else if let valueDouble = value as? Double {
                    dataDict[stringKey] = valueDouble
                } else if let valueNSString = value as? NSString{
                    dataDict[stringKey] = valueNSString
                } else {
                    LCLog.logI(message: "Unsupported value type for key: \(stringKey)")
                }
            }
        }
        let software = dataDict["software"] as? String
        if(software != nil && software == "live-chat-sdk"){
            if(!LiveChatSDK.isReceiveMessageFromFCM()) {return}
            let fromRaw = dataDict["sender"] as! String
            let fromDict = LCParseUtil.convertToDictionary(text: fromRaw)
            if(fromDict["id"] as! String == LiveChatSDK.getLCSession().visitorJid){
                return
            }
            let contentRaw = dataDict["content"] as! String
            let contentDict = LCParseUtil.convertToDictionary(text: contentRaw)
            let lcMessage = LCMessage(
                id: Int(dataDict["id"] as! String) ?? 0,
                mappingId: nil,
                content: LCParseUtil.contentFrom(contentRaw: contentDict),
                from: LCSender(
                    id: fromDict["id"] as! String,
                    name: fromDict["name"] as! String
                ),
                timeCreated: data["created_at"] as! String
            )
            LiveChatSDK.observingMessage(lcMesasge: lcMessage)
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
