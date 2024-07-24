//
//  LiveChatFactory.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 05/07/2024.
//

import Foundation

public class LiveChatFactory {
    public static func initializeSDK() {
        LiveChatSDK.initializeSDK()
    }
    
    public static func sendFileMessage(paths: [String], lcUser: LCUser, lcSession: LCSession){
        LiveChatSDK.sendFileMessage(paths: paths, lcUser: lcUser, lcSession: lcSession)
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
    
    public static func sendMessage(lcUser: LCUser, message: LCMessageSend){
        LiveChatSDK.sendMessage(lcUser: lcUser, message: message)
    }
    
    public static func getMessages(sessionId: String, offset: Int = 0, limit: Int = 5){
        LiveChatSDK.getMessages(sessionId: sessionId,offset: offset,limit: limit)
    }
    
    public static func enableDebug(isEnable: Bool){
        LiveChatSDK.enableDebug(isEnable: isEnable)
    }
}
