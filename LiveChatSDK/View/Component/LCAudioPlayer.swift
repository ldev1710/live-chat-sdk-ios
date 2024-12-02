//
//  LCAudioPlayer.swift
//  LiveChatSDK
//
//  Created by Luong Dien on 27/11/24.
//

import AVKit
import Foundation
import SwiftUI
import Combine

class SoundManager: ObservableObject {
    var audioPlayer: AVPlayer?
    var url: String
    var isPlaying: Bool = false
    @Published var currentTime: Double = 0 // Thời gian hiện tại của audio
    @Published var duration: Double = 0 // Tổng thời gian của audio

    private var timeObserverToken: Any?

    init(url: String) {
        self.url = url
    }

    func playSound() {
        if let url = URL(string: self.url) {
            self.audioPlayer = AVPlayer(url: url)

            // Lấy tổng thời gian của audio
            if let currentItem = audioPlayer?.currentItem {
                currentItem.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                    DispatchQueue.main.async {
                        let durationTime = CMTimeGetSeconds(currentItem.asset.duration)
                        self.duration = durationTime > 0 ? durationTime : 0
                    }
                }
            }

            // Theo dõi thời gian phát
            addPeriodicTimeObserver()
        }
    }

    func pause() {
        isPlaying = false
        audioPlayer?.pause()
        audioPlayer?.removeTimeObserver(timeObserverToken!)
    }
    
    func resume() {
        isPlaying = true
        audioPlayer?.play()
        addPeriodicTimeObserver()
    }
    
    func addPeriodicTimeObserver() {
        guard let player = audioPlayer else { return }

        // Quan sát thời gian hiện tại
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = CMTimeGetSeconds(time)
        }
    }

    func seek(to time: Double) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        audioPlayer?.seek(to: targetTime)
    }

    deinit {
        if let timeObserverToken = timeObserverToken {
            audioPlayer?.removeTimeObserver(timeObserverToken)
        }
    }
}
struct LCAudioPlayer: View {
    @State var song1 = false
    @ObservedObject private var soundManager: SoundManager
    @State var isFirstTime: Bool = true

    init(soundManager: SoundManager) {
        self.soundManager = soundManager
    }

    var body: some View {
        HStack {
            // Nút phát/tạm dừng
            Image(systemName: song1 ? "pause.circle.fill": "play.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.gray)
                .onTapGesture {
                    if(isFirstTime){
                        soundManager.playSound()
                        isFirstTime = false
                    }
                    song1.toggle()

                    if song1 {
                        soundManager.resume()
                    } else {
                        soundManager.pause()
                    }
                }

            if soundManager.duration > 0 {
                VStack {
                    Slider(
                        value: Binding(
                            get: { soundManager.currentTime },
                            set: { newValue in
                                soundManager.seek(to: newValue)
                            }
                        ),
                        in: 0...soundManager.duration,
                        step: 1
                    )
//                    .frame(height: 24)
//                    HStack {
//                        Text(formatTime(soundManager.currentTime))
//                            .font(.system(size: 8))
//                        Spacer()
//                        Text(formatTime(soundManager.duration))
//                            .font(.system(size: 8))
//                    }
                }
            } else {
                Text("Loading...")
                    .padding()
            }
        }
        .onAppear {
            soundManager.playSound()
        }
    }

    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && time.isFinite else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
