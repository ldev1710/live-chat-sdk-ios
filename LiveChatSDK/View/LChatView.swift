//
//  ChatView.swift
//  ExampleLiveChatSDKiOS
//
//  Created by Dev App Mitek on 25/07/2024.
//

import Foundation
import SwiftUI
import MobileCoreServices
import PhotosUI

extension LCMessageEntity : Hashable {
    public static func ==(lhs: LCMessageEntity, rhs: LCMessageEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LChatView: View {
    
    @State private var isFetching = true
    @State private var listener: LCListener?
    @State private var messages: [LCMessage]?
    @StateObject private var viewModel = LChatViewModel()
    @State private var showFilePicker = false
    @State private var showImagePicker = false
    @State private var selectedFile: [URL] = []
    @State private var selectedImages: [URL] = []
    @State private var isFetchingMore = false
    @State private var page = 1
    @State private var isCanFetchMore = true
    @State private var isInit = true
    @State private var scrollPosition: CGPoint = .zero
    @State private var limit = 10
    @State private var msgScrolling: LCMessageEntity?
    @State private var proxyGlo: ScrollViewProxy?
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        if(isCanFetchMore){
                            ProgressView()
                                .padding()
                                .onAppear {
                                    if(isInit){
                                        isInit = false
                                        return
                                    }
                                    isFetchingMore = true
                                    page += 1
                                    LiveChatFactory.getMessages(offset: page * limit, limit: limit)
                                }
                        }
                        ForEach(viewModel.messages.indices, id: \.self) { index in
                            LCMessageView(message: viewModel.messages[index],messageSize: viewModel.messages.count, messagePosition: index)
                                .padding(.vertical, 4)
                                .id(viewModel.messages[index].id)
                        }
                    }
                }
                .onAppear {
                    proxyGlo = proxy
                }
            }
            .padding(.horizontal)
            Spacer()
            GeometryReader {
                geometry in
                HStack {
                    TextField("Type a message", text: $viewModel.newMessageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: geometry.size.width * 0.65)
                    
                    Button(action: {
                        showFilePicker.toggle()
                    }) {
                        Image(systemName: "paperclip")
                            .foregroundColor(.blue)
                    }
                    .frame(width: geometry.size.width * 0.1)
                    .sheet(isPresented: $showFilePicker) {
                        LCDocumentPicker(
                            didPickDocuments: { urls in
                                selectedFile = urls
                                viewModel.sendFile(fileURL: selectedFile,contentType: "file")
                            }
                        )
                    }
                    
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                    }
                    .frame(width: geometry.size.width * 0.1)
                    .sheet(isPresented: $showImagePicker) {
                        LCPhotoPicker(){
                            images in
                            saveImagesToURLs(images: images){
                                urls in
                                viewModel.sendFile(fileURL: urls, contentType: "image")
                            }
                        }
                    }
                    
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                    }
                    .frame(width: geometry.size.width * 0.1)
                }
            }
            .frame(height: 70, alignment: .bottom)
            .padding([.leading,.trailing],8)
        }
        .onAppear(perform: {
            listener = LCListener(
                onReceiveMessage: self.onReceiveMessage,
                onGotDetailConversation: self.onGotDetailConversation,
                onInitSDKStateChange: self.onInitSDKStateChange,
                onAuthstateChanged: self.onAuthstateChanged,
                onInitialSessionStateChanged: self.onInitialSessionStateChanged,
                onSendMessageStateChange: self.onSendMessageStateChange
            )
            LiveChatFactory.addEventListener(listener: listener!)
            LiveChatFactory.getMessages(limit: limit)
        })
    }
    
    func onReceiveMessage(lcMessage: LCMessage) {
        viewModel.messages.append(LCMessageEntity(lcMessage: lcMessage, status: LCStatusMessage.sent))
        scrollToMsg(msg: viewModel.messages.last!)
    }
    
    func onGotDetailConversation(messages: [LCMessage]) {
        isCanFetchMore = messages.count >= limit
        if(isFetchingMore){
            var tmp: [LCMessageEntity] = []
            for(_, message) in messages.enumerated() {
                tmp.append(LCMessageEntity(lcMessage: message, status: LCStatusMessage.sent))
            }
            let msgTmp = viewModel.messages.first!
            viewModel.messages.insert(contentsOf: tmp.reversed(),at: 0)
            scrollToMsg(msg: msgTmp)
            isFetchingMore = false
        } else {
            var tmp: [LCMessageEntity] = []
            for(_, message) in messages.enumerated() {
                tmp.append(LCMessageEntity(lcMessage: message, status: LCStatusMessage.sent))
            }
            viewModel.messages = tmp.reversed()
            if(!viewModel.messages.isEmpty){
                scrollToMsg(msg: viewModel.messages.last!)
            }
        }
        isFetching = false
    }
    
    func scrollToMsg(msg: LCMessageEntity){
        DispatchQueue.main.async {
            proxyGlo!.scrollTo(msg.id, anchor: .bottom)
        }
        
    }
    
    func onInitSDKStateChange(state: LCInitialEnum, message: String) {
    }
    
    func onAuthstateChanged(success: Bool, message: String, lcAccount: LCAccount?) {
    }
    
    func onInitialSessionStateChanged(success: Bool, lcSession: LCSession) {
        
    }
    
    func onSendMessageStateChange(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?,mappingId: String?) {
        if(state == LCSendMessageEnum.SENDING) {
            viewModel.messages.append(LCMessageEntity(lcMessage: message!, status: LCStatusMessage.sending))
            scrollToMsg(msg: viewModel.messages.last!)
        } else if(state == LCSendMessageEnum.SENT_SUCCESS){
            let indexFound = viewModel.messages.firstIndex(where: {$0.lcMessage.mappingId == message?.mappingId})
            if(indexFound != nil && indexFound != -1){
                viewModel.messages[indexFound!].lcMessage = message!;
                viewModel.messages[indexFound!].status = LCStatusMessage.sent
                scrollToMsg(msg: viewModel.messages.last!)
            }
        }
    }
    
    func saveImagesToURLs(images: [UIImage], completion: @escaping ([URL]) -> Void) {
        var urls: [URL] = []
        for (index, image) in images.enumerated() {
            if let data = image.jpegData(compressionQuality: 1.0) {
                let filename = getDocumentsDirectory().appendingPathComponent("image\(index).jpg")
                do {
                    try data.write(to: filename)
                    urls.append(filename)
                } catch {
                }
            }
        }
        
        completion(urls)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}
