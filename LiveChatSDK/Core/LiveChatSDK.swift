//
//  Bar.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 05/07/2024.
//

import Foundation
import UserNotifications
import SocketIO
import SwiftUI
import UIKit

enum ChatViewError: Error {
    case invalidCondition(String)
}

public class LiveChatSDK {
    
    private static var isInitialized = false
    public static var isDebuging = false
    private static var isAvailable = false
    private static var listeners: [LCListener] = []
    private static var lcScripts: [LCScript] = []
    private static let socketManager = SocketManager(socketURL: URL(string: "https://s01-livechat-dev.midesk.vn/")!)
    private static var socket: SocketIOClient?
    private static var socketManagerClient: SocketManager?
    private static var socketClient: SocketIOClient?
    private static var currLCAccount: LCAccount?
    private static var lcSession: LCSession?
    private static var lcUser: LCUser?
    private static var accessToken: String!
    
    public static func initializeSDK() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { permission in
            let isGranted = permission.authorizationStatus == UNAuthorizationStatus.authorized
            if(!isGranted){
                LCLog.logI(message: "The library require notification permission!")
                return
            }
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
                let rawScripts = jsonData["script"] as! [Any]
                for rawScript in rawScripts {
                    let script = rawScript as! [String: Any]
                    var buttonActions: [LCButtonAction] = []
                    var answers: [LCAnswer] = []
                    let rawButtonActions = script["button_action"] as? [Any]
                    if(rawButtonActions != nil){
                        for rawButtonAction in rawButtonActions! {
                            let jsonButtonAction = rawButtonAction as! [String: String]
                            buttonActions.append(LCButtonAction(textSend: jsonButtonAction["button"]!, nextId: jsonButtonAction["next"]!))
                        }
                    }
                    let rawAnswers = script["answer"] as? [Any]
                    if(rawAnswers != nil){
                        for rawAnswer in rawAnswers! {
                            let jsonAnswers = rawAnswer as! [String: Any]
                            if let value = jsonAnswers["value"] as? String,
                               let type = jsonAnswers["type"] as? String {
                                answers.append(LCAnswer(type: type, value: value))
                            }
                        }
                    }
                    let lcScript = LCScript(id: script["id"] as! String, name: script["name"] as! String, nextAction: script["next_action"] as! String, answers: answers, buttonAction: buttonActions)
                    lcScripts.append(lcScript)
                }
                LCConstant.CLIENT_URL_SOCKET = jsonData["domain_socket"] as! String
                accessToken = jsonData["access_token"] as? String
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
                    let jsonRaw = data[0] as! [String: Any]
//                    print("RAW MSG: \(jsonRaw)")
                    let messageRaw = jsonRaw["data"] as! [String:Any]
                    let fromRaw = messageRaw["sender"] as! [String:Any]
                    let contentRaw = messageRaw["content"] as! [String:Any]
                    let lcMessage = LCMessage(
                        id: messageRaw["id"] as! Int,
                        mappingId: nil,
                        content: LCParseUtil.contentFrom(contentRaw: contentRaw),
                        from: LCSender(
                            id: fromRaw["id"] as! String,
                            name: fromRaw["name"] as! String
                        ),
                        timeCreated: messageRaw["created_at"] as! String
                    )
                    if(lcMessage.from.id == LiveChatSDK.getLCSession().visitorJid) {return}
                    observingMessage(lcMesasge: lcMessage)
                    
                }
                socketClient!.on(LCConstant.CONFIRM_SEND_MESSAGE){
                    data, ack in
                    let jsonRaw = data[0] as! [String: Any]
                    let messageRaw = jsonRaw["data"] as! [String:Any]
                    let fromRaw = messageRaw["from"] as! [String:Any]
                    let contentRaw = messageRaw["content"] as! [String:Any]
                    let mappingId = messageRaw["mapping_id"] as! String
                    let lCMessage = LCMessage(
                        id: messageRaw["id"] as! Int,
                        mappingId: mappingId,
                        content: LCParseUtil.contentFrom(contentRaw: contentRaw),
                        from: LCSender(
                            id: fromRaw["id"] as! String,
                            name: fromRaw["name"] as! String
                        ),
                        timeCreated: messageRaw["created_at"] as! String
                    )
                    observingSendMessage(state: LCSendMessageEnum.SENT_SUCCESS, message: lCMessage, errorMessage: nil,mappingId: lCMessage.mappingId)
                }
                socketClient!.on(LCConstant.RESULT_INITIALIZE_SESSION) {
                    data, ack in
                    let jsonData = data[0] as! [String: Any]
                    let success = jsonData["status"] as! Bool
                    let data = jsonData["data"] as! [String:Any]
                    let sessionId = data["session_id"] as! String
                    let visitorJid = data["visitor_jid"] as! String
                    observingInitialSession(sucess: success, lcSession: LCSession(sessionId: sessionId, visitorJid: visitorJid))
                }
                socketClient!.on(LCConstant.RESULT_GET_MESSAGES) {
                    data, ack in
                    let jsonData = data[0] as! [String: Any]
                    let rawMessages = jsonData["data"] as! [Any]
                    var messages: [LCMessage] = []
                    for rawMessage in rawMessages {
                        let jsonMessage = rawMessage as! [String:Any]
                        let fromRaw = jsonMessage["from"] as! [String:Any]
                        let message = LCMessage(
                            id: jsonMessage["id"] as! Int,
                            mappingId: nil,
                            content: LCParseUtil.contentFrom(contentRaw: jsonMessage["content"] as! [String:Any]),
                            from: LCSender(id: fromRaw["id"] as! String, name: fromRaw["name"] as! String),
                            timeCreated: jsonMessage["created_at"] as! String
                        )
                        messages.append(message)
                    }
                    observingGotMessages(messages: messages)
                }
                
                socketClient!.on(LCConstant.RESTART_SCRIPTING){
                    data,ack in
                    let jsonData = data[0] as! [String: Any]
                    LCLog.logI(message: "RESTART_SCRIPTING: \(jsonData)")
                    var buttonActions: [LCButtonAction] = []
                    let rawButtonActions = jsonData["button_action"] as? [Any]
                    if(rawButtonActions != nil){
                        for rawButtonAction in rawButtonActions! {
                            let jsonButtonAction = rawButtonAction as! [String: String]
                            buttonActions.append(LCButtonAction(textSend: jsonButtonAction["button"]!, nextId: jsonButtonAction["next"]!))
                        }
                        LCLog.logI(message: "buttonActions: \(buttonActions)")
                        observingRestartScriting(buttonActions: buttonActions)
                    }
                }
                
                socketClient?.connect()
            }
            socket!.connect()
        })
    }
    
    public static func viewEngine(onTapBack: @escaping() -> Void) -> some View {
        if(!isValid()){
            return AnyView(LCBlankView())
        } else {
            return AnyView(LChatView(onTapBack: onTapBack))
        }
    }
    
    public static func openChatView(viewController: UIViewController,onTapBack: @escaping() -> Void) {
        if(!isValid()){
            return
        }
        let chatViewController = LChatViewController(onTapBack: onTapBack)
        viewController.present(chatViewController, animated: true, completion: nil)
    }
    
    public static func setUserSession(lcSession: LCSession, lcUser:LCUser){
        self.lcUser = lcUser
        self.lcSession = lcSession
        socketClient?.emit(LCConstant.JOIN_SESSION, lcSession.sessionId)
    }
    
    public static func getScripts() -> [LCScript]{
        return lcScripts
    }
    
    public static func sendFileMessage(paths: [URL],contentType: String){
        if(!isValid()) {
            return
        }
        if(paths.count > 3){
            LCLog.logI(message: "You are only allowed to send a maximum of 3 files")
            return
        }
        let url = URL(string: LCConstant.CLIENT_URL_SOCKET+"/uploadSDK")!
        
        let uuid = UUID().uuidString
        
        let parameters:[String:String] = [
            "add_message_archive": "",
            "groupid": String(currLCAccount?.groupId ?? 0),
            "reply":"0",
            "mapping_id": uuid,
            "type":"live-chat-sdk",
            "from": lcSession!.visitorJid,
            "name": lcUser!.fullName,
            "session_id": lcSession!.sessionId,
            "host_name": currLCAccount?.hostName ?? "",
            "visitor_jid": lcSession!.visitorJid,
            "is_file":"1",
        ]
        
        var lcAttachments : [LCAttachment] = []
        for path in paths{
            lcAttachments.append(LCAttachment(url: path.absoluteString, fileName: path.lastPathComponent, fileExtension: path.pathExtension))
        }
        
        let lcMessage = LCMessage(
            id: -1,
            mappingId: uuid,
            content: LCContent(
                contentType: contentType,
                contentMessage: lcAttachments
            ),
            from: LCSender(
                id: lcSession!.visitorJid,
                name: lcUser!.fullName
            ),
            timeCreated: formattedCurrDate()
        )
        
        observingSendMessage(state: LCSendMessageEnum.SENDING, message: lcMessage, errorMessage: nil,mappingId: lcMessage.mappingId)
        uploadFiles(url: url, files: paths, parameters: parameters,lcMessageParams: lcMessage)
    }
    
    public static func initializeSession(user: LCUser,tokenFcm: String, supportType: LCSupportType){
        if(isReady()){
            var body:[String:Any] = [:]
            body[base64(text: "groupid")] = currLCAccount?.groupId
            body[base64(text: "access_token")] = accessToken
            body[base64(text: "host_name")] = currLCAccount?.hostName
            body[base64(text: "visitor_name")] = user.fullName
            body[base64(text: "visitor_email")] = user.email
            body[base64(text: "type")] = "live-chat-sdk"
            body[base64(text: "visitor_phone")] = user.phone
            body[base64(text: "url_visit")] = user.deviceName
            body[base64(text: "token")] = tokenFcm
            body[base64(text: "support_type_id")] = supportType.id
            socketClient?.emit(LCConstant.INITIALIZE_SESSION,body)
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
    
    public static func removeEventListener(listener: LCListener){
        let index = listeners.firstIndex(where: {listener.id == $0.id}) ?? -1
        if(index == -1){
            LCLog.logI(message: "Can not find listener id: \(listener.id)")
            return
        }
        listeners.remove(at: index)
    }
    
    public static func sendMessage(message: LCMessageSend, nextId: String?,position: Int?,currScriptId: String?){
        if(isValid()){
            var body:[String:Any] = [:]
            let uuid = UUID().uuidString
            body[base64(text: "groupid")] = currLCAccount?.groupId
            body[base64(text: "mapping_id")] = uuid
            body[base64(text: "host_name")] = currLCAccount?.hostName
            body[base64(text: "body")] = message.content
            body[base64(text: "id_next")] = nextId
            body[base64(text: "add_message_archive")] = ""
            body[base64(text: "reply")] = 0
            body[base64(text: "access_token")] = accessToken
            body[base64(text: "type")] = "live-chat-sdk"
            body[base64(text: "from")] = lcSession!.visitorJid
            body[base64(text: "name")] = lcUser!.fullName
            body[base64(text: "session_id")] = lcSession!.sessionId
            body[base64(text: "visitor_jid")] = lcSession!.visitorJid
            body[base64(text: "is_file")] = 0
            body[base64(text: "position")] = position
            body[base64(text: "curr_script_id")] = currScriptId
            
            socketClient?.emit(LCConstant.SEND_MESSAGE,body)

            observingSendMessage(
                state: LCSendMessageEnum.SENDING,
                message: LCMessage(
                    id: -1,
                    mappingId: uuid,
                    content: LCContent(
                        contentType: "text",
                        contentMessage: message.content
                    ),
                    from: LCSender(id: lcSession!.visitorJid, name: lcUser!.fullName),
                    timeCreated: formattedCurrDate()
                ),
                errorMessage: nil,
                mappingId: uuid
            )
        }
    }
    
    public static func getMessages(offset: Int = 0, limit: Int = 5){
        if(isValid()){
            var body:[String:Any] = [:]
            body[base64(text: "groupid")] = currLCAccount?.groupId
            body[base64(text: "host_name")] = currLCAccount?.hostName
            body[base64(text: "access_token")] = accessToken
            body[base64(text: "session_id")] = lcSession!.sessionId
            body[base64(text: "offset")] = offset
            body[base64(text: "limit")] = limit
            LCLog.logI(message: "Start get message")
            socketClient?.emit(LCConstant.GET_MESSAGES,body)
        }
    }
    
    public static func getLCSession() -> LCSession {
        return lcSession!
    }
    
    public static func getLCUser() -> LCUser{
        return lcUser!
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
    
    public static func observingRestartScriting(buttonActions: [LCButtonAction]){
        for listener in listeners {
            listener.onRestartScripting(buttonActions: buttonActions)
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
    
    public static func observingSendMessage(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?,mappingId: String?){
        for listener in listeners {
            listener.onSendMessageStateChange(state: state, message: message, errorMessage: errorMessage,mappingId: mappingId)
        }
    }
    
    private static func isReady() -> Bool{
        if(!(isInitialized && isAvailable)){
            LCLog.logI(message: "LiveChat SDK is not ready!")
            return false
        }
        return true
    }
    
    private static func isValid() -> Bool{
        if(!isReady()){
            return false
        }
        if(lcUser == nil || lcSession == nil) {
            LCLog.logI(message: "User session not has been set yet. Please call LiveChatFactory.setUserSession !")
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
    
    private static func uploadFiles(url: URL, files: [URL], parameters: [String: String],lcMessageParams: LCMessage) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer "+accessToken, forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createBody(with: parameters, files: files, boundary: boundary)
        request.httpBody = body
        
        let session = URLSession.shared
        DispatchQueue.main.async{
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    LCLog.logI(message: "Error: \(String(describing: error))")
                    observingSendMessage(state: LCSendMessageEnum.SENT_FAILED, message: lcMessageParams, errorMessage: String(describing: error),mappingId: nil)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    LCLog.logI(message: "Status code: \(httpResponse.statusCode)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                let respDict = LCParseUtil.convertToDictionary(text: responseString!)
                LCLog.logI(message: "Response: \(responseString ?? "")")
                let error = respDict["error"] as! Bool
                if(error) {
                    let errorMsg = respDict["message"] as! String
                    let dataDict = respDict["data"] as! [String: Any]
                    let mappingId = dataDict["mapping_id"] as! String
                    observingSendMessage(state: LCSendMessageEnum.SENT_FAILED, message: lcMessageParams, errorMessage: errorMsg, mappingId:mappingId)
                    return
                }
                let dataDict = respDict["data"] as! [String: Any]
                let fromRaw = dataDict["from"] as! [String: Any]
                let contentRaw = dataDict["content"] as! [String: Any]
                let lcMessage = LCMessage(
                    id: dataDict["id"] as! Int,
                    mappingId: dataDict["mapping_id"] as? String,
                    content: LCParseUtil.contentFrom(contentRaw: contentRaw),
                    from: LCSender(
                        id: fromRaw["id"] as! String,
                        name: fromRaw["name"] as! String
                    ),
                    timeCreated: dataDict["created_at"] as! String
                )
                observingSendMessage(state: LCSendMessageEnum.SENT_SUCCESS, message: lcMessage, errorMessage: nil,mappingId: lcMessage.mappingId)
            }
            
            task.resume()
        }
    }

    private static func createBody(with parameters: [String: String], files: [URL], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        for fileURL in files {
            LCLog.logI(message: "File absoluteString posting: \(fileURL.absoluteString)")
            let filename = fileURL.lastPathComponent
            let mimetype = "application/octet-stream" // Luôn sử dụng "application/octet-stream" cho mọi loại file
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"body\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            
            if let fileData = try? Data(contentsOf: fileURL) {
                body.append(fileData)
            } else {
                LCLog.logI(message: "Failed to read file data")
            }
            
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    public static func enableDebug(isEnable: Bool){
        isDebuging = isEnable
    }
    
    private static func formattedCurrDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
    
}
