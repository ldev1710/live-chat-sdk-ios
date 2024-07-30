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
    
    var body: some View {
        VStack(alignment: message.from.id == UserDefaults.standard.string(forKey: "currVisitorJid") ? .trailing : .leading) {
            Text(message.from.name)
                .font(.caption)
                .foregroundColor(.gray)
            if message.content.contentType == "text" {
                Text(message.content.contentMessage as? String ?? "")
                    .frame(alignment: .leading)
                    .padding()
                    .foregroundColor(Color(message.from.id == UserDefaults.standard.string(forKey: "currVisitorJid") ? .white : .black))
                    .background(Color(message.from.id == UserDefaults.standard.string(forKey: "currVisitorJid") ? .systemBlue : .systemGray5))
                    .cornerRadius(10)
            } else if message.content.contentType == "file" {
                if let contents = message.content.contentMessage as? [LCAttachment]{
                    ForEach(contents) { content in
                        HStack {
                            Image(systemName: "doc")
                            Text(content.fileName)
                        }
                        .frame(maxWidth: 200,alignment: .leading)
                        .padding()
                        .foregroundColor(Color(message.from.id == UserDefaults.standard.string(forKey: "currVisitorJid") ? .white : .black))
                        .background(Color(message.from.id == UserDefaults.standard.string(forKey: "currVisitorJid") ? .systemBlue : .systemGray5))
                        .cornerRadius(10)
                    }
                }
            } else if message.content.contentType == "image" {
                if let contents = message.content.contentMessage as? [LCAttachment] {
                    ForEach(contents) { content in
                        URLImage(url: URL(string: content.url)!)
                            .frame(width: 200, height: 300)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
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

