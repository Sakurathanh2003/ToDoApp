//
//  CrashlyticsLogEngine.swift
//  PlantIdentification
//
//  Created by Thanh Vu on 25/11/2020.
//

import Foundation
import FirebaseCrashlytics
import TLLogging

class CrashlyticsLogEngine: TLLoggingEngine {
    func log(_ content: String) {
        Crashlytics.crashlytics().log(content)
    }
}
