//
//  LCViewModel.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 30/07/2024.
//

import Foundation

class LChatViewModel: ObservableObject {
    @Published var messages: [LCMessageEntity] = []
    @Published var newMessageText: String = ""
    
    func sendMessage() {
        LiveChatFactory.sendMessage(message: LCMessageSend(content: newMessageText))
        newMessageText = ""
    }
    
    func sendFile(fileURL: [URL],contentType: String) {
        LiveChatFactory.sendFileMessage(paths: fileURL,contentType: contentType)
    }
}
