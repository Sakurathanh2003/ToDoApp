//
//  BlurView.swift
//  PrankCallDinosaur
//
//  Created by Mei Mei on 03/07/2023.
//

import UIKit

class BlurView: UIVisualEffectView {
    @IBInspectable var intensity: Double = 0.2 {
        didSet {
            animator?.fractionComplete = intensity
        }
    }
    
    private var animator: UIViewPropertyAnimator?

    deinit {
        animator?.stopAnimation(true)
        animator = nil
    }

    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupBlur()
    }

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)

        self.setupBlur()
    }

    // MARK: - Setup
    private func setupBlur() {
        animator?.stopAnimation(false)
        animator = nil
        effect = nil

        configAnimator()
    }

    private func configAnimator() {
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        animator?.pausesOnCompletion = true

        animator?.addAnimations { [weak self] in
            guard let self = self else {
                return
            }

            self.effect = UIBlurEffect(style: .dark)
        }

        animator?.fractionComplete = max(0, min(self.intensity, 1))
    }
}
