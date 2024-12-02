import AVKit
import Foundation
import SwiftUI
import Combine

class SoundManager: ObservableObject {
    var audioPlayer: AVPlayer?
    var url: String
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    private var timeObserverToken: Any?

    init(url: String) {
        self.url = url
        playSound()
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
        if(currentTime >= duration){
            audioPlayer?.seek(to: .zero)
        }
        isPlaying = true
        audioPlayer?.play()
        addPeriodicTimeObserver()
    }
    
    func addPeriodicTimeObserver() {
        guard let player = audioPlayer else { return }
        // Quan sát thời gian hiện tại
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = CMTimeGetSeconds(time)
            if(self!.currentTime >= self!.duration){
                self!.audioPlayer?.seek(to: .zero)
                self!.pause()
            }
        }
    }

    func seek(to time: Double) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        audioPlayer?.seek(to: targetTime)
    }

    deinit {
        if let timeObserverToken = timeObserverToken {
//            audioPlayer?.removeTimeObserver(timeObserverToken)
        }
    }
}
struct LCAudioPlayer: View {
    @State var from: String
    @ObservedObject private var soundManager: SoundManager
    @State var isFirstTime: Bool = true

    init(soundManager: SoundManager,from: String) {
        self.soundManager = soundManager
        self.from = from
    }

    var body: some View {
        HStack {
            // Nút phát/tạm dừng
            Image(systemName: soundManager.isPlaying ? "pause.circle.fill": "play.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(from ==  LiveChatSDK.getLCSession().visitorJid ? .white : .gray)
                .onTapGesture {
                    if(isFirstTime){
                        soundManager.playSound()
                        isFirstTime = false
                    }
                    soundManager.isPlaying.toggle()

                    if soundManager.isPlaying {
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
                    .accentColor(Color(from ==  LiveChatSDK.getLCSession().visitorJid ? .white : .systemBlue))
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
    }

    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && time.isFinite else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
