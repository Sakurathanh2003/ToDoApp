//
//  AppManager.swift
//  PlantIdentification
//
//  Created by Viet Le Van on 11/18/20.
//

import Foundation
import UIKit

class AppManager {
    static let shared = AppManager()

    func increaseLauchingCounter() {
        UserDefaults.standard.setValue(self.launchingCounter() + 1, forKey: "AppLaunchingCounter")
    }

    func launchingCounter() -> Int {
        return UserDefaults.standard.integer(forKey: "AppLaunchingCounter")
    }
}
