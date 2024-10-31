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
    
    public static func sendFileMessage(paths: [URL],contentType: String /* 'image' or 'file' */){
        LiveChatSDK.sendFileMessage(paths: paths,contentType: contentType)
    }
    
    public static func initializeSession(user: LCUser,tokenFcm:String, supportType: LCSupportType){
        LiveChatSDK.initializeSession(user: user,tokenFcm: tokenFcm, supportType: supportType)
    }
    
    public static func getScripts() -> [LCScript]{
        return LiveChatSDK.getScripts()
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
    
    public static func sendMessage(message: LCMessageSend,position: Int? = nil, currScriptId: String? = nil){
        LiveChatSDK.sendMessage(message: message, nextId: nil,position: position,currScriptId: currScriptId)
    }
    
    public static func sendMessageScript(message: LCMessageSend, nextId: String){
        LiveChatSDK.sendMessage(message: message, nextId: nextId, position: nil, currScriptId: nil)
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
    
    public static func openChatView(viewController: UIViewController, onTapBack: @escaping ()-> Void) {
        LiveChatSDK.openChatView(viewController: viewController,onTapBack: onTapBack)
    }
    
    public static func viewEngine(onTapBack: @escaping() -> Void) -> some View {
        return LiveChatSDK.viewEngine(onTapBack: onTapBack)
    }
}
