//
//  UserDataRepository.swift
//  Teleprompter
//
//  Created by Manh Nguyen Ngoc on 25/10/2021.
//

import UIKit

class UserDataRepository {
    static let shared = UserDataRepository()
    
    private let userDefault = UserDefaults.standard
    private let firstShowIntroScreen = "firstShowIntroScreen"
    private let numberOfProjectsCreated = "numberOfProjectsCreated"

    // MARK: - First Show Intro Screen
    func setTheFirstShowIntroScreen(isTheFirst: Bool) {
        userDefault.setValue(isTheFirst, forKey: firstShowIntroScreen)
    }
    
    func getTheFirstShowIntroScreen() -> Bool {
        userDefault.bool(forKey: firstShowIntroScreen)
    }

    // MARK: - Premium Feature
    func setPremiumFeatureState(isOn: Bool, featureName: String) {
        userDefault.setValue(isOn, forKey: featureName)
    }

    func getPremiumFeatureState(featureName: String) -> Bool {
        userDefault.bool(forKey: featureName)
    }

    // MARK: - Get number of projects created
    func getNumberOfProjectsCreated() -> Int {
        userDefault.integer(forKey: numberOfProjectsCreated)
    }

    func updateNumberOfProjectsCreated(number: Int) {
        userDefault.set(number, forKey: numberOfProjectsCreated)
    }

    func increaseNumberOfProjectsCreated() {
        let number = getNumberOfProjectsCreated()
        updateNumberOfProjectsCreated(number: number + 1)
    }
    
    func hasValueForKey(key: String) -> Bool {
        return userDefault.value(forKey: key) != nil
    }
}
