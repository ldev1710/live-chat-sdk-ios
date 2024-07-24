//
//  Bar.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 05/07/2024.
//

import Foundation
import UserNotifications
import SocketIO
import Firebase

public class LiveChatSDK {
    
    private static var isInitialized = false
    public static var isDebuging = false
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
                let success = json["status"] as! Bool
                isAvailable = success
                LCLog.logI(message: "Is available: \(isAvailable)")
                if(!success){
                    observingAuthorize(sucess: false, message: "Un-authorized", lcAccount: nil)
                    return
                }
                let dataResp = data[0] as! [String:Any]
                let jsonData = dataResp["data"] as! [String:Any]
                LCConstant.CLIENT_URL_SOCKET = jsonData["domain_socket"] as! String
                LCLog.logI(message: "\(LCConstant.CLIENT_URL_SOCKET)")
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
                    let contentRaw = messageRaw["content"] as! [String:Any]
                    let lCMessage = LCMessage(
                        id: messageRaw["id"] as! Int,
                        content: LCParseUtil.contentFrom(contentRaw: contentRaw),
                        from: LCSender(
                            id: fromRaw["id"] as! String,
                            name: fromRaw["name"] as! String
                        ),
                        timeCreated: messageRaw["created_at"] as! String
                    )
                    observingSendMessage(state: LCSendMessageEnum.SENT_SUCCESS, message: lCMessage, errorMessage: nil)
                }
                socketClient!.on(LCConstant.RESULT_INITIALIZE_SESSION){
                    data, ack in
                    let jsonData = data[0] as! [String: Any]
                    let success = jsonData["status"] as! Bool
                    let sessionId = jsonData["session_id"] as! String
                    let visitorJid = jsonData["visitor_jid"] as! String
                    Messaging.messaging().subscribe(toTopic: sessionId) { error in
                        LCLog.logI(message: "Has subscribe to topic: \(sessionId)")
                    }
                    observingInitialSession(sucess: success, lcSession: LCSession(sessionId: sessionId, visitorJid: visitorJid))
                }
                socketClient?.connect()
            }
            
            socket!.on(LCConstant.RESULT_GET_MESSAGES) {
                data, ack in
                let jsonData = data[0] as! [String: Any]
                let rawMessages = jsonData["data"] as! [Any]
                var messages: [LCMessage] = []
                for rawMessage in rawMessages {
                    let jsonMessage = rawMessage as! [String:Any]
                    let fromRaw = jsonMessage["from"] as! [String:Any]
                    let message = LCMessage(
                        id: jsonMessage["id"] as! Int,
                        content: LCParseUtil.contentFrom(contentRaw: jsonMessage["content"] as! [String:Any]),
                        from: LCSender(id: fromRaw["id"] as! String, name: fromRaw["name"] as! String),
                        timeCreated: jsonMessage["created_at"] as! String
                    )
                    messages.append(message)
                }
                observingGotMessages(messages: messages)
            }
            
            socket!.connect()
        })
    }
    
    public static func sendFileMessage(paths: [String], lcUser: LCUser, lcSession: LCSession){
        let url = URL(string: "https://s01-livechat-dev.midesk.vn/upload")!
        var files:[URL] = []
        for path in paths {
            files.append(URL(fileURLWithPath: path))
        }
        
        let parameters:[String:String] = [
            "add_message_archive": "",
            "groupid": String(currLCAccount?.groupId ?? 0),
            "reply":"0",
            "type":"\"live-chat-sdk\"",
            "from": "\"\(lcSession.visitorJid)\"",
            "name": "\"\(lcUser.fullName)\"",
            "session_id": "\"\(lcSession.sessionId)\"",
            "host_name": "\"\(currLCAccount?.hostName ?? "")\"",
            "visitor_jid": "\"\(lcSession.visitorJid)\"",
            "is_file":"1",
        ]

        uploadFiles(url: url, files: files, parameters: parameters)

    }
    
    public static func initializeSession(user: LCUser, supportType: LCSupportType){
        if(isValid()){
            Messaging.messaging().token { token, error in
              if let error = error {
                  LCLog.logI(message: "Error fetching FCM registration token: \(error)")
              } else if let token = token {
                  LCLog.logI(message: token)
                  var body:[String:Any] = [:]
                  body[base64(text: "groupid")] = currLCAccount?.groupId
                  body[base64(text: "host_name")] = currLCAccount?.hostName
                  body[base64(text: "visitor_name")] = user.fullName
                  body[base64(text: "visitor_email")] = user.email
                  body[base64(text: "type")] = "live-chat-sdk"
                  body[base64(text: "visitor_phone")] = user.phone
                  body[base64(text: "url_visit")] = user.deviceName
                  body[base64(text: "token")] = token
                  body[base64(text: "support_type_id")] = supportType.id
                  socketClient?.emit(LCConstant.INITIALIZE_SESSION,body)
              }
            }
        }
    }
    
    public static func authorize(apiKey: String){
        if(isInitialized){
            socket!.emit(LCConstant.AUTHENTICATION, apiKey)
        }
    }
    
    public static func addEventListener(listener: LCListener){
        listeners.append(listener)
    }
    
    public static func sendMessage(lcUser: LCUser, message: LCMessageSend){
        if(isValid()){
            observingSendMessage(state: LCSendMessageEnum.SENDING, message: nil, errorMessage: nil)
            var body:[String:Any] = [:]
            body[base64(text: "groupid")] = currLCAccount?.groupId
            body[base64(text: "host_name")] = currLCAccount?.hostName
            body[base64(text: "body")] = message.content
            body[base64(text: "add_message_archive")] = ""
            body[base64(text: "reply")] = 0
            body[base64(text: "type")] = "live-chat-sdk"
            body[base64(text: "from")] = message.lcSession.visitorJid
            body[base64(text: "name")] = lcUser.fullName
            body[base64(text: "session_id")] = message.lcSession.sessionId
            body[base64(text: "visitor_jid")] = message.lcSession.visitorJid
            body[base64(text: "is_file")] = 0
            socketClient?.emit(LCConstant.SEND_MESSAGE,body)
        }
    }
    
    public static func getMessages(sessionId: String, offset: Int = 0, limit: Int = 5){
        if(isValid()){
            var body:[String:Any] = [:]
            body[base64(text: "groupid")] = currLCAccount?.groupId
            body[base64(text: "host_name")] = currLCAccount?.hostName
            body[base64(text: "session_id")] = sessionId
            body[base64(text: "offset")] = offset
            body[base64(text: "limit")] = limit
            LCLog.logI(message: "Start get message")
            socket?.emit(LCConstant.GET_MESSAGES,body)
        }
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
    
    private static func base64(text: String) -> String {
        if let data = text.data(using: .utf8) {
            let base64encoded = data.base64EncodedString()
            return base64encoded
        }
        return "\(text): None"
    }
    
    private static func uploadFiles(url: URL, files: [URL], parameters: [String: String]) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createBody(with: parameters, files: files, boundary: boundary)
        request.httpBody = body
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                LCLog.logI(message:"Error: \(String(describing: error))")
                observingSendMessage(state: LCSendMessageEnum.SENT_SUCCESS, message: nil, errorMessage: String(describing: error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                LCLog.logI(message:"Status code: \(httpResponse.statusCode)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let respDict = LCParseUtil.convertToDictionary(text: responseString!)
            LCLog.logI(message:"Response: \(responseString ?? "")")
            let dataDict = respDict["data"] as! [String: Any]
            let fromRaw = dataDict["from"] as! [String:Any]
            let contentRaw = dataDict["content"] as! [String:Any]
            let lcMessage = LCMessage(
                id: dataDict["id"] as! Int,
                content: LCParseUtil.contentFrom(contentRaw: contentRaw),
                from: LCSender(
                    id: fromRaw["id"] as! String,
                    name: fromRaw["name"] as! String
                ),
                timeCreated: dataDict["created_at"] as! String
            )
            observingSendMessage(state: LCSendMessageEnum.SENT_SUCCESS, message: lcMessage, errorMessage: nil)
        }
        
        task.resume()
    }

    private static func createBody(with parameters: [String: String], files: [URL], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        for fileURL in files {
            let filename = fileURL.lastPathComponent
            let mimetype = "application/octet-stream" // Luôn sử dụng "application/octet-stream" cho mọi loại file
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"body\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            
            if let fileData = try? Data(contentsOf: fileURL) {
                body.append(fileData)
            }
            
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    public static func enableDebug(isEnable: Bool){
        isDebuging = isEnable
    }
    
}
