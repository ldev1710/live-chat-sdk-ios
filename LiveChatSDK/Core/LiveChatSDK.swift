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
    private static let socketManager = SocketManager(socketURL: URL(string: "https://s01-livechat-dev.midesk.vn/")!)
    private static var socket: SocketIOClient?
    private static var socketManagerClient: SocketManager?
    private static var socketClient: SocketIOClient?
    private static var currLCAccount: LCAccount?
    
    public static func initializeSDK() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { permission in
            let isGranted = permission.authorizationStatus == UNAuthorizationStatus.authorized
            if(!isGranted){
                LCLog.logI(message: "The library require notification permission!")
                return
            }
            // Create a Socket.IO client
            socket = socketManager.defaultSocket
            observingInitSDK(state: LCInitialEnum.PROCESSING, message: "LiveChatSDK initial is processing")
            
            socket!.on(LCConstant.CONFIRM_CONNECT){
                data,emitter in
                isInitialized = true
                observingInitSDK(state: LCInitialEnum.SUCCESS, message: "Initial SDK successful!")
            }
            socket!.on(LCConstant.RESULT_AUTHENTICATION){
                data,emitter in
                let json = data[0] as! [String: Any]
                LCLog.logI(message: "\(json)")
                let success = json["status"] as! Bool
                isAvailable = success
                if(!success){
                    observingAuthorize(sucess: false, message: "Un-authorized", lcAccount: nil)
                    return
                }
                let dataResp = data[0] as! [String:Any]
                let jsonData = dataResp["data"] as! [String:Any]
                LCConstant.CLIENT_URL_SOCKET = jsonData["domain_socket"] as! String
                let rawSupportTypes = jsonData["support_type"] as! [Any]
                var supportTypes: [LCSupportType] = []
                for rawSupportType in rawSupportTypes {
                    let jsonSpt = rawSupportType as! [String: String]
                    let lcSpt = LCSupportType(id: jsonSpt["id"]!, name: jsonSpt["name"]!)
                    supportTypes.append(lcSpt)
                }
                currLCAccount = LCAccount(
                    id: jsonData["id"] as! Int,
                    groupId: jsonData["groupid"] as! Int,
                    groupName: jsonData["group_name"] as! String,
                    socketDomain: jsonData["domain_socket"] as! String,
                    hostName: jsonData["for_domain"] as! String,
                    supportType: supportTypes
                )
                do {
                    socketManagerClient = SocketManager(socketURL: URL(string: LCConstant.CLIENT_URL_SOCKET)!)
                    socketClient = socketManagerClient?.defaultSocket
                    socketClient!.on(LCConstant.CONFIRM_CONNECT){
                        data, ack in
                        observingAuthorize(sucess: true, message: "Authorization successful", lcAccount: currLCAccount)
                    }
                    socketClient!.on(LCConstant.RECEIVE_MESSAGE){
                        data, ack in
                        
                    }
                    socketClient!.on(LCConstant.CONFIRM_SEND_MESSAGE){
                        data, ack in
                        let jsonRaw = data[0] as! [String: Any]
                        let messageRaw = jsonRaw["data"] as! [String:Any]
                        let fromRaw = messageRaw["from"] as! [String:Any]
                        let contentRaw = messageRaw["content"]
                        
                    }
                } catch {
                    
                }
            }
            socket!.connect()
        })
    }
    
    public static func sendFileMessage(paths: [String], lcUser: LCUser, lcSession: LCSession){
        
    }
    
    public static func initializeSession(user: LCUser, supportType: LCSupportType){
        
    }
    
    public static func authorize(apiKey: String){
        if(isInitialized){
            socket!.emit(LCConstant.AUTHENTICATION, apiKey)
        }
    }
    
    public static func addEventListener(listener: LCListener){
        LCLog.logI(message: "Da add event")
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
            LCLog.logI(message: "Da observe")
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
