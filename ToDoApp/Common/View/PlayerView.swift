//
//  PlayerView.swift
//
//
//  Created by Mei Mei on 12/10/2022.
//

import AVFoundation
import UIKit
import TLLogging

@objc public protocol PlayerViewDelegate: AnyObject {
    func playerViewBeganInterruptAudioSession(_ view: PlayerView)
    func playerViewUpdatePlayingState(_ view: PlayerView, isPlaying: Bool)
    func playerViewDidPlaying(_ view: PlayerView, _ progress: Double)
    func playerViewConnectNetWork(_ view: PlayerView)
    
    @objc optional func playerViewReadyToPlay(_ view: PlayerView)
    @objc optional func playerViewFailToLoad(_ view: PlayerView)
    @objc optional func playerViewPlayToEnd(_ view: PlayerView)
}

open class PlayerView: UIView {
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer! {
        return self.layer as? AVPlayerLayer
    }

    public weak var delegate: PlayerViewDelegate?
    public var loopEnable: Bool = false
    public var pauseWhenEnterBackground: Bool = true
    private var timerObserver: Any?
    
    public var isMuted: Bool {
        get {
            return player.isMuted
        }

        set {
            player.isMuted = newValue
        }
    }

    public var isFailed: Bool = false

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initPlayer()
        registerNotifications()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        initPlayer()
        registerNotifications()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        self.playerLayer.frame = self.bounds
    }

    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    private func initPlayer() {
        self.player = AVPlayer()
        self.player.addObserver(self, forKeyPath: "rate", options: [.initial, .new], context: nil)
        self.playerLayer.player = self.player
        self.playerLayer.frame = self.bounds
    }

    deinit {
        self.player.removeObserver(self, forKeyPath: "rate")

        if let playerItem = self.player.currentItem {
            playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        }
    }

    // MARK: - Observer
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status = self.player.currentItem?.status
            if status == .readyToPlay {
                TLLogging.log("Player item ready to play \(self.player.currentItem?.description ?? "")")
                self.delegate?.playerViewReadyToPlay?(self)
            }

            if status == .failed {
                TLLogging.log("Player item failed \(self.player.currentItem?.description ?? "")")
                self.delegate?.playerViewFailToLoad?(self)
                self.player.replaceCurrentItem(with: nil)
            }
        }
    }

    // MARK: - Notifications
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionIterruptionNotification(_:)), name: AVAudioSession.interruptionNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActiveNotification(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectNetworkDidChange(notification:)), name: .didChangeConnectNetworkActivity, object: nil)
    }
    
    public func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didChangeConnectNetworkActivity, object: nil)
    }
    
    @objc func connectNetworkDidChange(notification: Notification) {
        if MonitorNetwork.shared.isConnectedNetwork() {
            delegate?.playerViewConnectNetWork(self)
        }
    }

    @objc func playerItemDidPlayToEnd(_ notification: Notification) {
        if self.loopEnable {
            self.player.seek(to: .zero)
            self.play()
        }

        self.delegate?.playerViewPlayToEnd?(self)
        self.delegate?.playerViewUpdatePlayingState(self, isPlaying: false)
    }

    @objc func applicationWillResignActiveNotification(_ notification: Notification) {
        if self.pauseWhenEnterBackground {
            self.pause()
        }
    }

    @objc private func audioSessionIterruptionNotification(_ notification: Notification) {
        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
           let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
               return
        }

        if type == .began {
            self.pause()
            delegate?.playerViewBeganInterruptAudioSession(self)
        }
    }

    // MARK: - Audio session
    private func activeAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Public
    public func play() {
        activeAudioSession()
        self.player.play()
        self.delegate?.playerViewUpdatePlayingState(self, isPlaying: true)
    }

    public func pause() {
        self.player.pause()
        self.delegate?.playerViewUpdatePlayingState(self, isPlaying: false)
    }

    @discardableResult
    public func replacePlayerItem(_ item: AVPlayerItem?) -> Bool {
        if let oldItem = self.player.currentItem {
            if let newItem = item, comparePlayerItem(lhs: oldItem, rhs: newItem) {
                return false
            }

            oldItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: oldItem)
        }

        self.player.replaceCurrentItem(with: item)
        if item != nil {
            item?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item!)
        }

        return true
    }

    public func seekTo(_ time: TimeInterval) {
        let cmtime = CMTime.init(seconds: time, preferredTimescale: 3600)
        self.player.seek(to: cmtime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func seekTo(_ time: CMTime) {
        player.seek(to: time)
    }

    public func addTimeObserver(forInterval interval: CMTime, queue: DispatchQueue = .main, using: @escaping (CMTime) -> Void) -> Any {
        return self.player.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: using)
    }

    public func removeTimeObserver(_ obj: Any) {
        self.player.removeTimeObserver(obj)
    }

    private func comparePlayerItem(lhs: AVPlayerItem, rhs: AVPlayerItem) -> Bool {
        guard let lhsAsset = lhs.asset as? AVURLAsset,
              let rhsAsset = rhs.asset as? AVURLAsset else {
            return false
        }

        return lhsAsset.url == rhsAsset.url
    }
    
    func addPlayerObserver() {
        let interval = CMTime(value: 1, timescale: 60)
        timerObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
            guard let self = self else { return }
            
            guard let item = self.player.currentItem else { return }
            let progress = time.seconds / item.duration.seconds
            self.delegate?.playerViewDidPlaying(self, progress)
        })
    }
    
    func removePlayerObserver() {
        if let timerObserver = timerObserver {
            player.removeTimeObserver(timerObserver)
        }
    }

    public func setLayerVideoGravity(_ value: AVLayerVideoGravity) {
        playerLayer.videoGravity = value
    }

    public func rate() -> Float {
        return player.rate
    }

    public func duration() -> CMTime {
        return player.currentItem?.duration ?? .zero
    }
    
    public func currentTime() -> CMTime {
        return player.currentTime()
    }

    public func isPlaying() -> Bool {
        return player.rate != 0
    }
}
