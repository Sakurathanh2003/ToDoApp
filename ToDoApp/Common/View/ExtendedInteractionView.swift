//
//  ExtendedInteractionView.swift
//  PlantIdentification
//
//  Created by Linh Nguyen Duc on 02/04/2021.
//

import UIKit

class ExtendedInteractionView: UIView {
    var areaInteractiveInsets = UIEdgeInsets(top: -15, left: -15, bottom: 15, right: 15)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = CGRect(x: areaInteractiveInsets.left, y: areaInteractiveInsets.top, width: self.frame.width + areaInteractiveInsets.right - areaInteractiveInsets.left, height: self.frame.height + areaInteractiveInsets.bottom - areaInteractiveInsets.top)
        return rect.contains(point)
    }
}
