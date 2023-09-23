//
//  AVAudioFileExtensions.swift
//
//  Created by Thanh Vu on 17/02/2021.
//

import Foundation
import AVFoundation
public extension AVAudioFile {
    var duration: TimeInterval {
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }
}
