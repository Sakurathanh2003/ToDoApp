//
//  DictionaryExtension.swift
//
//  Created by thanhvu on 7/13/20.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation

public extension Dictionary {
    func jsonString() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else {
            return ""
        }

        return String(data: jsonData, encoding: .utf8) ?? ""
    }
}
