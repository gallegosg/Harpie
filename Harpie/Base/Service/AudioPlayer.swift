//
//  AudioPlayer.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 3/11/25.
//

import AVFoundation

class AudioPlayer {
    private var player: AVPlayer?
    
    func playAudio(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Start playback
        player?.play()
        print("Playing audio from: \(urlString)")
    }
    
    func pause() {
        player?.pause()
        print("Paused audio")
    }
    
    func stop() {
        player?.pause()
        player = nil
        print("Stopped audio")
    }
}
