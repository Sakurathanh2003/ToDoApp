//
//  Validator.swift
//  PlantIdentification
//
//  Created by Viet Le Van on 11/12/20.
//

import Foundation

class Validator {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    static func isValidLetterString(_ string: String) -> Bool {
        let letterRegEx = "[A-Z0-9a-z._() ]+"
        let letterPred = NSPredicate(format:"SELF MATCHES %@", letterRegEx)
        return letterPred.evaluate(with: string)
    }

    static func isValidUserName(_ userName: String) -> Bool {
        let userRegEx = "[A-Z0-9a-z._%+-]+"
        let userPred = NSPredicate(format:"SELF MATCHES %@", userRegEx)
        return userPred.evaluate(with: userName)
    }
}
