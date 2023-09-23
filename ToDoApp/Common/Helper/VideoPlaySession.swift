//
//  PlayerSessionManager.swift
//  PlantIdentification
//
//  Created by Linh Nguyen Duc on 15/10/2021.
//

import Foundation
import AVFoundation

class VideoPlaySession {
    var player: AVPlayer?
    var needToPlayFromZero = false
    var playerStatusControlledByUser = AVPlayer.TimeControlStatus.playing
    
    var isPlaying: Bool {
        return player?.rate != 0
    }
}
