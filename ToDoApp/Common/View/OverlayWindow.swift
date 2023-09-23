//
//  OverlayWindow.swift
//  SetTimer
//
//  Created by Manh Nguyen Ngoc on 02/07/2021.
//

import Foundation
import UIKit

private class OverlayRootView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}

private class OverlayRootVC: UIViewController {
    var isHideStatusBar: Bool = false
    override func loadView() {
        self.view = OverlayRootView()
        self.view.backgroundColor = UIColor.clear
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let keyWindow = UIApplication.shared.keyWindow!
        return keyWindow.rootViewController?.topVC().preferredStatusBarStyle ?? .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHideStatusBar
    }
}

class OverlayWindow: UIWindow {
    private var currentView: UIView?
    fileprivate var rootVC: OverlayRootVC!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.windowLevel = .statusBar + 1
        self.isHidden = false
        self.rootVC = OverlayRootVC()
        self.rootViewController = self.rootVC
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showBannerView(_ view: UIView, animated: Bool = true) {
        self.currentView?.removeFromSuperview()
        self.currentView = view
        self.rootVC.isHideStatusBar = true
        self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        
        if !animated {
            self.addSubview(view)
        } else {
            let originFrame = view.frame
            var frame = originFrame
            frame.origin.y = -originFrame.size.height
            
            view.frame = frame
            self.addSubview(view)
            self.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3) {
                view.frame = originFrame
                self.layoutIfNeeded()
            }
        }
    }
    
    func hideBannerView(_ view: UIView, animated: Bool = true) {
        self.currentView = nil
        
        if !animated {
            view.removeFromSuperview()
        } else {
            var frame = view.frame
            frame.origin.y = -frame.size.height
            
            UIView.animate(withDuration: 0.3, animations: {
                view.frame = frame
            }, completion: { _ in
                view.removeFromSuperview()
                
                self.rootVC.isHideStatusBar = false
                self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var result = false
        
        self.subviews.reversed().forEach { (subview) in
            if NSStringFromClass(type(of: subview)) == "UITransitionView" {
                return
            }
            
            let location = self.convert(point, to: subview)
            
            let isInside = subview.point(inside: location, with: event)
            if isInside {
                result = true
            }
        }
        
        return result
    }
}
