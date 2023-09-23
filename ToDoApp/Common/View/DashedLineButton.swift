//
//  DashedLineButton.swift
//  PhotoConverter
//
//  Created by Vu Thanh on 14/06/2022.
//

import UIKit

class DashedLineButton: UIButton {

    @IBInspectable var borderColorDash :UIColor = UIColor.black
    private let border = CAShapeLayer()
        
    override func draw(_ rect: CGRect) {
        border.lineWidth = 2
        border.frame = self.bounds
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).cgPath
        self.layer.addSublayer(border)
            
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        setDashBorder()
    }
    
    func setDashBorder() {
        border.lineDashPattern = [2, 2]
        border.strokeColor = borderColorDash.cgColor
    }
}
