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
import UniformTypeIdentifiers

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
    let onTapBack: () -> Void
    
    init(onTapBack: @escaping () -> Void) {
        self.onTapBack = onTapBack
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    onTapBack()
                }) {
                    Image(systemName: "chevron.backward") // Bạn có thể thay đổi tên hệ thống của biểu tượng nếu muốn
                        .foregroundColor(.blue)
                    Text("Back")
                        .foregroundColor(.blue)
                }
            }
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
                            result in
                            switch result {
                            case .success(let media):
                                if(media.isEmpty){
                                    return
                                }
                                switch media.first! {
                                case .image(let uiImage):
                                    saveImagesToURLs(images: [uiImage]){
                                        urls in
                                        viewModel.sendFile(fileURL: urls, contentType: determineFileType(from: urls.first!))
                                    }
                                    
                                case .video(let url, let thumbnail):
                                    let destinationURL = getDocumentsDirectory().appendingPathComponent("video-lc.mp4")
                                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                                        do {
                                            try FileManager.default.removeItem(atPath: destinationURL.path)
                                        } catch {
                                            print("Could not delete file, probably read-only filesystem")
                                        }
                                    }
                                    do {
                                        try FileManager.default.copyItem(at: url, to: destinationURL)
                                    } catch {
                                        print("Error copying video file: \(error)")
                                    }
                                    viewModel.sendFile(fileURL: [destinationURL], contentType: determineFileType(from: destinationURL))
                                }
                            case .failure(let error):
                                print("Error picking media: \(error.localizedDescription)")
                            }
                        }
                    }
                    Button(action: {
                        if(viewModel.newMessageText.isEmpty) {return}
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
        .preferredColorScheme(.light)
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
        viewModel.messages.append(LCMessageEntity(lcMessage: lcMessage, status: LCStatusMessage.sent,errormessage: nil))
        scrollToMsg(msg: viewModel.messages.last!)
    }
    
    func onGotDetailConversation(messages: [LCMessage]) {
        isCanFetchMore = messages.count >= limit
        if(isFetchingMore){
            var tmp: [LCMessageEntity] = []
            for(_, message) in messages.enumerated() {
                tmp.append(LCMessageEntity(lcMessage: message, status: LCStatusMessage.sent,errormessage: nil))
            }
            let msgTmp = viewModel.messages.first!
            viewModel.messages.insert(contentsOf: tmp.reversed(),at: 0)
            scrollToMsg(msg: msgTmp)
            isFetchingMore = false
        } else {
            var tmp: [LCMessageEntity] = []
            for(_, message) in messages.enumerated() {
                tmp.append(LCMessageEntity(lcMessage: message, status: LCStatusMessage.sent,errormessage: nil))
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
    func determineFileType(from url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased() // Lấy phần mở rộng tệp và chuyển về chữ thường
        
        if let uti = UTType(filenameExtension: fileExtension) {
            if uti.conforms(to: .image) {
                return "image"
            } else if uti.conforms(to: .movie) || uti.conforms(to: .video) {
                return "video"
            }
        }
        
        return "Unknown"
    }
    func onInitSDKStateChange(state: LCInitialEnum, message: String) {
    }
    
    func onAuthstateChanged(success: Bool, message: String, lcAccount: LCAccount?) {
    }
    
    func onInitialSessionStateChanged(success: Bool, lcSession: LCSession) {
        
    }
    
    func onSendMessageStateChange(state: LCSendMessageEnum, message: LCMessage?, errorMessage: String?,mappingId: String?) {
        if(state == LCSendMessageEnum.SENDING) {
            viewModel.messages.append(LCMessageEntity(lcMessage: message!, status: LCStatusMessage.sending,errormessage: nil))
            scrollToMsg(msg: viewModel.messages.last!)
        } else {
            let indexFound = viewModel.messages.firstIndex(where: {$0.lcMessage?.mappingId == message?.mappingId})
            if(indexFound != nil && indexFound != -1){
                viewModel.messages[indexFound!].lcMessage = message!;
                viewModel.messages[indexFound!].status = (state == LCSendMessageEnum.SENT_SUCCESS) ? LCStatusMessage.sent : LCStatusMessage.sentFailed
                viewModel.messages[indexFound!].errorMessage = errorMessage
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
    
    func saveVideosToURLs(videos: [URL], completion: @escaping ([URL]) -> Void) {
        var urls : [URL] = []
        for (index, videoURL) in videos.enumerated() {
                let filename = getDocumentsDirectory().appendingPathComponent("video\(index).mp4") // Đặt đuôi file là .mp4
                do {
                    // Sao chép video từ URL nguồn sang thư mục đích
                    try FileManager.default.copyItem(at: videoURL, to: filename)
                    urls.append(filename)
                } catch {
                    print("Error saving video \(index): \(error)")
                }
            }
        completion(urls)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
