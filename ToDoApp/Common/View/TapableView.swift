//
//  TapableView.swift
//
//  Created by Thanh Vu on 18/11/2020.
//

import UIKit
import RxCocoa
import RxSwift

public class TapableView: UIControl {
    @IBInspectable var scaleOnHighlight: CGFloat = 0.8
    @IBInspectable var alphaTouchBegan: CGFloat = 0.6
    @IBInspectable var delayEventDuration: Double = 0.5
    @IBInspectable var interactiveInset: UIEdgeInsets = .zero
    private var isPreventTouch = false

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPreventTouch {
            return
        }

        super.touchesBegan(touches, with: event)
        self.animate(alpha: alphaTouchBegan, scale: self.scaleOnHighlight)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPreventTouch {
            return
        }

        self.animate(alpha: 1, scale: 1)

        let location = touches.first!.location(in: self)
        if self.bounds.inset(by: self.interactiveInset).contains(location) {
            self.sendActions(for: .touchUpInside)
            self.disableOverrideInteractiveFor(seconds: delayEventDuration)
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPreventTouch {
            return
        }

        super.touchesCancelled(touches, with: event)
        self.animate(alpha: 1, scale: 1)
    }

    private func animate(alpha: CGFloat, scale: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = alpha
            if scale == 1 {
                self.transform = .identity
            } else {
                self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            }
        }
    }

    private func disableOverrideInteractiveFor(seconds: Double) {
        if seconds == 0 {
            return
        }

        self.isPreventTouch = true
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.isPreventTouch = false
        }
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.bounds.inset(by: self.interactiveInset).contains(point)
    }
}

public extension Reactive where Base: TapableView {
    var tap: ControlEvent<Void> {
        controlEvent(.touchUpInside)
    }

    var isEnabled: Binder<Bool> {
        return Binder.init(self.base) { target, isEnable in
            target.isUserInteractionEnabled = isEnable
            target.alpha = isEnable ? 1 : 0.6
        }
    }
}
