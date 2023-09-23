//
//  DeviceExtensions.swift
//
//  Created by Thanh Vu on 04/04/2021.
//  Copyright © 2021 Thanh Vu. All rights reserved.
//

import Foundation
import UIKit

public extension UIDevice {
    class var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
