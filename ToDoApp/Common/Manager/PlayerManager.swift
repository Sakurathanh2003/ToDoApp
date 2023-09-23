//
//  PlayerManager.swift
//  VO-VoiceChange
//
//  Created by Manh Nguyen Ngoc on 30/12/2021.
//

import UIKit
import AVFoundation

protocol PlayerManagerDelegate: AnyObject {
    func playerManagerDidPlayToEndTime(_ playerManager: PlayerManager)
    func playerManagerDidPlaying(_ playerManager: PlayerManager, _ progress: Double)
}

class PlayerManager {
    
    weak var delegate: PlayerManagerDelegate?
    var oldRatePlayer: Float = 0
    var isLoop = true
    private(set) var player = AVPlayer()
    private var item: AVPlayerItem!
    private var timerObserver: Any?
    
    func configAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    func configPlayer(url: URL) {
        item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.pause()
    }
    
    func setVolume(_ volume: Float) {
        player.volume = volume
    }
    
    func isMutedAudio() -> Bool {
        return player.volume == 0
    }
    
    func isPlaying() -> Bool {
        return player.rate != 0
    }
    
    func timeDuration() -> CMTime {
        return player.currentItem?.duration ?? .zero
    }
    
    func seekTo(_ time: CMTime) {
        player.seek(to: time)
    }
    
    func currentRate() -> Float {
        return player.rate
    }
    
    func replaceItem(_ item: AVPlayerItem) {
        player.replaceCurrentItem(with: item)
    }
    
    func currentTime() -> CMTime {
        return player.currentTime()
    }
    
    // MARK: - Notification
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    @objc private func playerItemDidPlayToEndTime() {
        player.seek(to: .zero)
        if isLoop {
            player.play()
        }
        
        delegate?.playerManagerDidPlayToEndTime(self)
    }
    
    // MARK: - Time Observer
    func addPlayerObserver() {
        let interval = CMTime(value: 1, timescale: 60)
        timerObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
            guard let self = self else { return }
            
            guard let item = self.player.currentItem else { return }
            let progress = time.seconds / item.duration.seconds
            self.delegate?.playerManagerDidPlaying(self, progress)
        })
    }
    
    func removePlayerObserver() {
        if let timerObserver = timerObserver {
            player.removeTimeObserver(timerObserver)
        }
    }
}
