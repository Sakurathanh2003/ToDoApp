//
//  EmptiableViewModel.swift
//  ChargingAnimation
//
//  Created by Manh Nguyen Ngoc on 07/04/2022.
//

import Foundation

public protocol EmptiableViewModel {
    static func makeEmpty() -> Self
}
