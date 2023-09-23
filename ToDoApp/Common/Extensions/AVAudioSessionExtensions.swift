//
//  AVAudioSessionExtensions.swift
//  CoreUtils
//
//  Created by Thanh Vu on 02/04/2022.
//

import Foundation
import AVFoundation

public extension AVAudioSession {
    static func active(category: Category = .playback) {
        try? AVAudioSession.sharedInstance().setCategory(category)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
