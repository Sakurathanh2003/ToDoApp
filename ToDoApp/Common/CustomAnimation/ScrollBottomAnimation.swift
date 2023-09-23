//
//  ScrollBottomAnimation.swift
//  MoneyManager
//
//  Created by Mei Mei on 24/07/2023.
//

import UIKit

class ScrollBottomAnimation: NSObject {
    private let animationDuration: Double
    private let animationType: AnimationType

    public enum AnimationType {
        case present
        case dismiss
    }

    init(animationDuration: Double, animationType: AnimationType) {
        self.animationType = animationType
        self.animationDuration = animationDuration
    }
}

extension ScrollBottomAnimation: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(exactly: self.animationDuration) ?? 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        switch animationType {
        case .present:
            self.presentAnimation(with: transitionContext, viewToAnimate: toViewController.view)
        case .dismiss:
            transitionContext.containerView.addSubview(fromViewController.view)
            self.dismissAnimation(with: transitionContext, viewToAnimate: fromViewController.view)
        }
    }

    func presentAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        let blackView = UIView()
        blackView.tag = 100
        blackView.backgroundColor = .black.withAlphaComponent(0.84)
        blackView.alpha = 0
        blackView.translatesAutoresizingMaskIntoConstraints = false

        transitionContext.containerView.addSubview(blackView)
        transitionContext.containerView.addSubview(viewToAnimate)
        blackView.fitSuperviewConstraint()
        viewToAnimate.fitSuperviewConstraint()
        viewToAnimate.transform = .init(translationX: 0, y: viewToAnimate.bounds.height)

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, delay: 0) {
            viewToAnimate.transform = .init(translationX: 0, y: 0)
            blackView.alpha = 1
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }

    func dismissAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        let blackView = transitionContext.containerView.viewWithTag(100)
        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, delay: 0) {
            viewToAnimate.transform = .init(translationX: 0, y: viewToAnimate.bounds.height)
            blackView?.alpha = 0
        } completion: { _ in
            blackView?.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}

