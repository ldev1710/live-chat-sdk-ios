//
//  Bar.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 05/07/2024.
//

import Foundation
import UserNotifications
import SocketIO
public class LiveChatSDK {
    
    private static var isInitialized = false
    private static var isAvailable = false
    private static var listeners: [LCListener] = []
//    private static var socket: SocketIOClient = SocketManager(socketURL: URL(string: "https://s01-livechat-dev.midesk.vn/")!).defaultSocket
    private static var socketClient: SocketManager?
    
    public static func initializeSDK() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { permission in
            let isGranted = permission.authorizationStatus == UNAuthorizationStatus.authorized
            if(!isGranted){
                LCLog.logI(message: "The library require notification permission!")
                return
            }
            // Create a Socket.IO manager instance
            let socketManager = SocketManager(socketURL: URL(string: "https://s01-livechat-dev.midesk.vn")!, config: [.log(true), .compress])

            // Create a Socket.IO client
            let socket = socketManager.defaultSocket
            socket.on(clientEvent: .connect) { data, ack in
                print("Socket connected")
            }
            LCLog.logI(message: "Bat dau")
            observingInitSDK(state: LCInitialEnum.PROCESSING, message: "LiveChatSDK initial is processing")
            LCLog.logI(message: "Da observe")
            socket.on(LCConstant.CONFIRM_CONNECT){
                data,emitter in
                LCLog.logI(message: "Da confirm")
                isInitialized = true
                observingInitSDK(state: LCInitialEnum.SUCCESS, message: "Initial SDK successful!")
            }
            socket.on(LCConstant.RESULT_AUTHENTICATION){
                data,emitter in
                let json = data[0] as! [String: Any]
                LCLog.logI(message: "\(json)")
                let success = json["status"] as! Bool
                LCLog.logI(message: "\(json)")
                isAvailable = success
                if(!success){
                    observingAuthorize(sucess: false, message: "Un-authorized", lcAccount: nil)
                    return
                }
                let dataResp = data[0] as! [String:Any]
                let jsonData = dataResp["data"] as! [String:Any]
                LCConstant.CLIENT_URL_SOCKET = jsonData["domain_socket"] as! String
                let rawSupportTypes = jsonData["support_type"] as! [Any]
            }
            
            socket.connect()
            LCLog.logI(message: "Da connect")
        })
    }
    
    public static func sendFileMessage(paths: [String], lcUser: LCUser, lcSession: LCSession){
        
    }
    
    public static func initializeSession(user: LCUser, supportType: LCSupportType){
        
    }
    
    public static func authorize(apiKey: String){
        
    }
    
    public static func addEventListener(listener: LCListener){
        listeners.append(listener)
    }
    
    public static func sendMessage(lcUser: LCUser, message: LCMessageSend){
        
    }
    
    public static func getMessages(sessionId: String, offset: Int = 0, limit: Int = 5){
        
    }
    
    public static func observingMessage(lcMesasge:LCMessage){
        for listener in listeners {
            listener.onReceiveMessage(lcMessage: lcMesasge)
        }
    }
    
    public static func observingGotMessages(messages: [LCMessage]){
        for listener in listeners {
            listener.onGotDetailConversation(messages: messages)
        }
    }
    
    public static func observingInitSDK(state: LCInitialEnum, message: String){
        for listener in listeners {
            listener.onInitSDKStateChange(state: state, message: message)
        }
    }
    
    public static func observingAuthorize(sucess: Bool, message: String, lcAccount: LCAccount?){
        for listener in listeners {
            listener.onAuthstateChanged(success: sucess, message: message, lcAccount: lcAccount)
        }
    }
    
    public static func observingInitialSession(sucess: Bool, lcSession: LCSession){
        for listener in listeners {
            listener.onInitialSessionStateChanged(success: sucess, lcSession: lcSession)
        }
    }
    
    public static func observingSendMessage(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?){
        for listener in listeners {
            listener.onSendMessageStateChange(state: state, message: message, errorMessage: errorMessage)
        }
    }
    
    private static func isValid() -> Bool{
        if(!(isInitialized && isAvailable)){
            LCLog.logI(message: "LiveChat SDK is not ready!")
            return false
        }
        return true
    }
    
}
