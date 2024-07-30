//
//  LCURLImage.swift
//  LiveChatSDK
//
//  Created by Dev App Mitek on 30/07/2024.
//

import Foundation
import SwiftUI

struct URLImage: View {
    @StateObject private var loader = LCImageLoader()
    let placeholder: UIImage
    let imageUrl: URL
    
    init(url: URL, placeholder: UIImage = UIImage(systemName: "photo")!) {
        self.imageUrl = url
        self.placeholder = placeholder
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 10)) // Bo nhẹ 4 góc
            .onAppear {
                loader.load(from: imageUrl)
            }
    }

    private var image: Image {
        if let uiImage = loader.image {
            return Image(uiImage: uiImage)
        } else {
            return Image(uiImage: placeholder)
        }
    }
}
