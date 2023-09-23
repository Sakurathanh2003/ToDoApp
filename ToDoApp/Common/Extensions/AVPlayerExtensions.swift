//
//  AVPlayerExtensions.swift
//  PrankSounds
//
//  Created by Linh Nguyen Duc on 23/08/2022.
//

import Foundation
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0
    }
}
