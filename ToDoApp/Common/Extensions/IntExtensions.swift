//
//  IntExtensions.swift
//
//  Created by Le Toan on 8/21/20.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation

private struct IntConst {
    static let pow3: Int = 1000
    static let pow6: Int = 1000000
    static let pow9: Int = 1000000000
}

public extension Int {
    func timeString() -> String {
        let minute = self / 60 % 60
        let second = self % 60

        // return formated string
        return String(format: "%02d:%02d", minute, second)
    }

    func shortDescription() -> String {
        if self < IntConst.pow3 {
            return "\(self)"
        }

        if self < IntConst.pow6 {
            return String(format: "%fk", Double(self * 10 / IntConst.pow3) / 10)
        }

        if self < IntConst.pow9 {
            return String(format: "%fM", Double(self * 10 / IntConst.pow6) / 10)
        }

        return String(format: "%fB", Double(self * 10 / IntConst.pow9) / 10)
    }

    func memorySizeDescription() -> String {
        if self < IntConst.pow3 {
            return "\(self)B"
        }

        if self < IntConst.pow6 {
            return String(format: "\(Int((Double(self * 10 / IntConst.pow3) / 10).rounded()))KB")
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.decimalSeparator = "."

        if self < IntConst.pow9 {
            return String(format: "\(numberFormatter.string(from: (Double(self) * 10 / Double(IntConst.pow6)).rounded() / 10 as NSNumber)!)MB")
        }

        return String(format: "\(numberFormatter.string(from: (Double(self) * 10 / Double(IntConst.pow9)).rounded() / 10 as NSNumber)!)GB")
    }
}
