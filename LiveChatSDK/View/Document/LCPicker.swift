//
//  DocumentPicker.swift
//  ExampleLiveChatSDKiOS
//
//  Created by Dev App Mitek on 26/07/2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct LCDocumentPicker: UIViewControllerRepresentable {
    var didPickDocuments: ([URL]) -> Void

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: LCDocumentPicker

        init(parent: LCDocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.didPickDocuments(urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data], asCopy: true)
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = true
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

struct LCPhotoPicker: UIViewControllerRepresentable {
    var didPickMedia: (Result<[Media], Error>) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .videos]) // Cho phép chọn cả ảnh và video
        configuration.selectionLimit = 1 // Giới hạn số lượng tệp chọn (0 là không giới hạn)

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: LCPhotoPicker

        init(_ parent: LCPhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            var pickedMedia: [Media] = []
            var errors: [Error] = []

            let dispatchGroup = DispatchGroup()

            for result in results {
                dispatchGroup.enter()

                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    // Load UIImage for images
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let error = error {
                            errors.append(error)
                        } else if let image = object as? UIImage {
                            pickedMedia.append(.image(image))
                        }
                        dispatchGroup.leave()
                    }
                } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    // Load URL for videos
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                        if let error = error {
                            errors.append(error)
                        } else if let url = url {
                            // Tạo thumbnail từ video
                            if let thumbnail = self.generateThumbnail(from: url) {
                                pickedMedia.append(.video(url, thumbnail))
                            }
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave() // Không hỗ trợ loại tệp khác
                }
            }

            dispatchGroup.notify(queue: .main) {
                if errors.isEmpty {
                    self.parent.didPickMedia(.success(pickedMedia))
                } else {
                    self.parent.didPickMedia(.failure(errors.first!))
                }
            }
        }

        // Tạo thumbnail từ video
        private func generateThumbnail(from url: URL) -> UIImage? {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true

            do {
                let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                return UIImage(cgImage: cgImage)
            } catch {
                print("Error generating thumbnail: \(error)")
                return nil
            }
        }
    }
}

// Enum để phân biệt ảnh và video
enum Media {
    case image(UIImage)
    case video(URL, UIImage) // Thêm thumbnail cho video
}
