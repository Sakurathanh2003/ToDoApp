//
//  AudioPlayerManager.swift
//  Teleprompter
//
//  Created by Manh Nguyen Ngoc on 29/10/2021.
//

import UIKit
import AVFoundation

class AudioPlayerManager {
    static let shared = AudioPlayerManager()
    
    var player: AVAudioPlayer!
    
    func configAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    func playAudio(resource: String, extensions: String, isMute: Bool = false, isLoop: Bool = false) {
        do {
            let url = Bundle.main.url(forResource: resource, withExtension: extensions)
            player = try AVAudioPlayer(contentsOf: url!)
            
            if isMute {
                setVolume(0)
            } else {
                setVolume(1)
            }
            
            if isLoop {
                player.numberOfLoops = -1
            }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print("Failed to init audio player: \(error)")
        }
    }
    
    func isMutedAudio() -> Bool {
        return player.volume == 0
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        if player != nil {
            player.stop()
        }
    }
    
    func setVolume(_ volume: Float) {
        player.volume = volume
    }
}
