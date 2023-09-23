//
//  TimeIntervalExtensions.swift
//
//  Created by VietLV on 7/13/20.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation
import AVFoundation

public extension TimeInterval {
    func toDurationString() -> String {
        let seconds: Int = Int(self.rounded()) % 60
        let minutes = Int(self.rounded() / 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func toFullDurationString() -> String {
        let seconds: Int = Int(self.rounded()) % 60
        let minutes = Int(self.rounded() / 60)
        let hours: Int = Int(self.rounded() / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func cgFloat() -> CGFloat {
        return CGFloat(self)
    }
}

public extension CMTime {
    func toDouble() -> Float64 {
        return CMTimeGetSeconds(self)
    }
}
