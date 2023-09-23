//
//  SkippableInteractionView.swift
//  StickmanAnimation
//
//  Created by Linh Nguyen Duc on 10/04/2023.
//

import UIKit

class SkippableInteractionView: UIView {
    var didTouchedBlock: (() -> Void)?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTest = super.hitTest(point, with: event)
        if hitTest == self {
            didTouchedBlock?()
            return nil
        }

        return hitTest
    }
}
