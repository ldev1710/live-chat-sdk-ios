//
//  LCMessageView.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 30/07/2024.
//

import Foundation
import SwiftUI

struct LCMessageView: View {
    let message: LCMessage
    public var onRemoveMessage: (LCMessage)->()
    
    var body: some View {
        VStack(alignment: message.from.id == LiveChatSDK.getLCSession().visitorJid ? .trailing : .leading) {
            Text(message.from.name)
                .font(.caption)
                .foregroundColor(.gray)
            if message.content.contentType == "text" {
                Text(message.content.contentMessage as? String ?? "")
                    .frame(alignment: .leading)
                    .padding()
                    .foregroundColor(Color(message.from.id ==  LiveChatSDK.getLCSession().visitorJid ? .white : .black))
                    .background(Color(message.from.id ==  LiveChatSDK.getLCSession().visitorJid ? .systemBlue : .systemGray5))
                    .cornerRadius(10)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message.content.contentMessage as? String
                        }) {
                            Label("Sao chép", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            onRemoveMessage(message)
                        }) {
                            Label("Xoá tin nhắn", systemImage: "trash")
                        }
                    }
            } else if message.content.contentType == "file" {
                if let contents = message.content.contentMessage as? [LCAttachment]{
                    ForEach(contents) { content in
                        HStack {
                            Image(systemName: "doc")
                            Text(content.fileName)
                        }
                        .frame(maxWidth: 200,alignment: .leading)
                        .padding()
                        .foregroundColor(Color(message.from.id ==  LiveChatSDK.getLCSession().visitorJid ? .white : .black))
                        .background(Color(message.from.id == LiveChatSDK.getLCSession().visitorJid ? .systemBlue : .systemGray5))
                        .cornerRadius(10)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = content.url
                            }) {
                                Label("Sao chép", systemImage: "doc.on.doc")
                            }
                            
                            Button(action: {
                                onRemoveMessage(message)
                            }) {
                                Label("Xoá tin nhắn", systemImage: "trash")
                            }
                        }
                    }
                }
            } else if message.content.contentType == "image" {
                if let contents = message.content.contentMessage as? [LCAttachment] {
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
                                
                                Button(action: {
                                    onRemoveMessage(message)
                                }) {
                                    Label("Xoá tin nhắn", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            Text(message.timeCreated)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: message.from.id == UserDefaults.standard.string(forKey: "currVisitorJid") ? .trailing : .leading)
    }
}

