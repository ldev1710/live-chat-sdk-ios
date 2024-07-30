//
//  LiveChatFactory.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 05/07/2024.
//

import Foundation
import SwiftUI
import UIKit

public class LiveChatFactory {
    public static func initializeSDK() {
        LiveChatSDK.initializeSDK()
    }
    
    public static func sendFileMessage(paths: [URL]){
        LiveChatSDK.sendFileMessage(paths: paths)
    }
    
    public static func initializeSession(user: LCUser, supportType: LCSupportType){
        LiveChatSDK.initializeSession(user: user, supportType: supportType)
    }
    
    public static func authorize(apiKey: String){
        LiveChatSDK.authorize(apiKey: apiKey)
    }
    
    public static func addEventListener(listener: LCListener){
        LiveChatSDK.addEventListener(listener: listener)
    }
    
    public static func removeEventListener(listener: LCListener){
        LiveChatSDK.removeEventListener(listener:listener)
    }
    
    public static func sendMessage(message: LCMessageSend){
        LiveChatSDK.sendMessage(message: message)
    }
    
    public static func getMessages(offset: Int = 0, limit: Int = 5){
        LiveChatSDK.getMessages(offset: offset,limit: limit)
    }
    
    public static func enableDebug(isEnable: Bool){
        LiveChatSDK.enableDebug(isEnable: isEnable)
    }
    
    public static func setUserSession(lcSession: LCSession, lcUser:LCUser){
        LiveChatSDK.setUserSession(lcSession: lcSession, lcUser: lcUser)
    }
    
    public static func openChatView(viewController: UIViewController) {
        LiveChatSDK.openChatView(viewController: viewController)
    }
    
    public static func viewEngine() -> some View {
        LCLog.logI(message: "View engine called")
        return LiveChatSDK.viewEngine()
    }
}
