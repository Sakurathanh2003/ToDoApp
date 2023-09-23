//
//  Switch.swift
//  StickmanAnimation
//
//  Created by Mei Mei on 09/03/2023.
//

import UIKit

@IBDesignable
class Switch: UISwitch {
    @IBInspectable var scale : CGFloat = 0.5

    override func draw(_ rect: CGRect) {
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
