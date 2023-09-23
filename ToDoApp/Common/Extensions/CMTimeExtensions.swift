//
//  CMTimeExtensions.swift
//
//  Created by Thanh Vu on 26/03/2021.
//  Copyright © 2021 Thanh Vu. All rights reserved.
//

import Foundation
import CoreMedia

public extension CMTime {
    func toDurationString() -> String {
        let seconds: Int = Int(self.seconds) % 60
        let minutes = Int(self.seconds / 60)
        return String.init(format: "%02d:%02d", minutes, seconds)
    }
}
