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

extension LCMessage : Equatable {
    public static func ==(lhs: LCMessage, rhs: LCMessage) -> Bool {
        return lhs.id == rhs.id
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
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { value in
                    ForEach(viewModel.messages) { message in
                        LCMessageView(message: message,onRemoveMessage: self.onRemoveMessage)
                            .padding(.vertical, 4)
                    }.onChange(of: viewModel.messages) { _ in
                        value.scrollTo(viewModel.messages.count - 1)
                    }
                }
            }
            .padding(.horizontal)
            
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
                                viewModel.sendFile(fileURL: selectedFile)
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
                                viewModel.sendFile(fileURL: urls)
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
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                })
            }
            listener = LCListener(
                onReceiveMessage: self.onReceiveMessage,
                onGotDetailConversation: self.onGotDetailConversation,
                onInitSDKStateChange: self.onInitSDKStateChange,
                onAuthstateChanged: self.onAuthstateChanged,
                onInitialSessionStateChanged: self.onInitialSessionStateChanged,
                onSendMessageStateChange: self.onSendMessageStateChange
            )
            LiveChatFactory.addEventListener(listener: listener!)
            LiveChatFactory.getMessages()
        })
    }
    
    func onRemoveMessage(lcMessage: LCMessage) {
        viewModel.messages.remove(at: viewModel.messages.firstIndex(of: lcMessage)!)
    }
    
    func onReceiveMessage(lcMessage: LCMessage) {
        viewModel.messages.append(lcMessage)
    }
    
    func onGotDetailConversation(messages: [LCMessage]) {
        viewModel.messages = messages.reversed()
        isFetching = false
    }
    
    func onInitSDKStateChange(state: LCInitialEnum, message: String) {
    }
    
    func onAuthstateChanged(success: Bool, message: String, lcAccount: LCAccount?) {
    }
    
    func onInitialSessionStateChanged(success: Bool, lcSession: LCSession) {
        
    }
    
    func onSendMessageStateChange(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?) {
        if(state == LCSendMessageEnum.SENT_SUCCESS){
            viewModel.messages.append(message!)
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
                    LCLog.logI(message: "Error when copying image: \(error)")
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

#Preview{
    LChatView()
}
