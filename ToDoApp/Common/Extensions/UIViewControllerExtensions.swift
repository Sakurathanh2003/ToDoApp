//
//  UIViewControllerExtensions.swift
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC
import RxSwift
import TLLogging

private struct Keys {
    static var disposeBagKey = ""
}

public extension UIViewController {
    func topVC() -> UIViewController {
        if let navigation = self as? UINavigationController, !navigation.viewControllers.isEmpty {
            return navigation.topViewController!.topVC()
        }

        if let presentedVC = self.presentedViewController {
            return presentedVC.topVC()
        }

        return self
    }

    func popToBefore(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigation = self.navigationController ?? self as? UINavigationController else {
            DCHECK(false)
            return
        }

        if let index = navigation.viewControllers.firstIndex(of: viewController), index > 0 {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                CATransaction.flush()
                completion?()
            }

            navigation.popToViewController(navigation.viewControllers[index-1], animated: animated)
            CATransaction.commit()
        } else {
            completion?()
        }
    }
}

public extension UIViewController {
    var disposeBag: DisposeBag {
        if let bag = objc_getAssociatedObject(self, &Keys.disposeBagKey) as? DisposeBag {
            return bag
        }

        let bag = DisposeBag()
        objc_setAssociatedObject(self, &Keys.disposeBagKey, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return bag
    }
    
    func postAlert(_ title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async(execute: { () -> Void in
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                completion?()
            }))
            
            let popOver = alert.popoverPresentationController
            popOver?.sourceView  = self.view
            popOver?.sourceRect = self.view.bounds
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
            
            self.present(alert, animated: true, completion: nil)
        })
    }
}
