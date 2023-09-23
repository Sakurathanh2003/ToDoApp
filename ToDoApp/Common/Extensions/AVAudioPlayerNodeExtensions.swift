//
//  AVAudioPlayerNodeExtensions.swift
//
//  Created by Thanh Vu on 17/02/2021.
//

import Foundation
import AVFoundation

public extension AVAudioPlayerNode {
    var currentTime: TimeInterval {
        if let nodeTime = lastRenderTime, let playerTime = playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }

        return 0
    }
}
