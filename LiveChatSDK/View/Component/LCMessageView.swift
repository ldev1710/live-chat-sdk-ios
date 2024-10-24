//
//  LCMessageView.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 30/07/2024.
//

import Foundation
import SwiftUI

struct LCMessageView: View {
    @ObservedObject var message: LCMessageEntity
    let messageSize: Int
    let messagePosition: Int
    @State var currentScript: LCScript
    let lcScripts: [LCScript]
    @State var isScripting: Bool
    @State var isWaiting: Bool
    let onTapScript: (LCButtonAction) -> Void
    
    var body: some View {
        VStack(alignment: message.lcMessage.from.id == LiveChatSDK.getLCSession().visitorJid ? .trailing : .leading) {
            Text(message.lcMessage.from.name)
                .font(.caption)
                .foregroundColor(.gray)
            if message.lcMessage.content.contentType == "text" {
                Text(message.lcMessage.content.contentMessage as? String ?? "")
                    .frame(alignment: .leading)
                    .padding()
                    .foregroundColor(Color(message.lcMessage.from.id ==  LiveChatSDK.getLCSession().visitorJid ? .white : .black))
                    .background(Color(message.lcMessage.from.id ==  LiveChatSDK.getLCSession().visitorJid ? .systemBlue : .systemGray5))
                    .cornerRadius(10)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message.lcMessage.content.contentMessage as? String
                        }) {
                            Label("Sao chép", systemImage: "doc.on.doc")
                        }
                    }
            } else if message.lcMessage.content.contentType == "file" {
                if let contents = message.lcMessage.content.contentMessage as? [LCAttachment]{
                    ForEach(contents) { content in
                        HStack {
                            Image(systemName: "doc")
                            Text(content.fileName)
                        }
                        .frame(maxWidth: 200,alignment: .leading)
                        .padding()
                        .foregroundColor(Color(message.lcMessage.from.id ==  LiveChatSDK.getLCSession().visitorJid ? .white : .black))
                        .background(Color(message.lcMessage.from.id == LiveChatSDK.getLCSession().visitorJid ? .systemBlue : .systemGray5))
                        .cornerRadius(10)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = content.url
                            }) {
                                Label("Sao chép", systemImage: "doc.on.doc")
                            }
                        }
                    }
                }
            } else if message.lcMessage.content.contentType == "image" {
                if let contents = message.lcMessage.content.contentMessage as? [LCAttachment] {
                    ForEach(contents) { content in
                        URLImage(url: URL(string: content.url)!)
                            .frame(width: 200, height: 300)
                            .cornerRadius(8)
                            .shadow(radius: 10)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = content.url
                                }) {
                                    Label("Sao chép", systemImage: "doc.on.doc")
                                }
                            }
                    }
                }
            }
            Text(message.lcMessage.timeCreated)
                .font(.caption)
                .foregroundColor(.gray)
            if(message.lcMessage.from.id == LiveChatSDK.getLCSession().visitorJid) {
                if(message.status == LCStatusMessage.sending){
                    Text("Đang gửi")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    if(messagePosition == messageSize - 1){
                        Text("Đã gửi")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            if(messagePosition == messageSize - 1 && !lcScripts.isEmpty && isScripting == true && !self.isWaiting){
                LCScriptView(scripts: lcScripts, currentScript: currentScript,isScripting: isScripting,onTapScript: onTapScript)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.lcMessage.from.id == LiveChatSDK.getLCSession().visitorJid ? .trailing : .leading)
    }
}

