//  BaseViewController.swift

import Foundation
import UIKit
import RxSwift
import TLLogging

open class BaseViewControler: UIViewController {
    private(set) var viewWillAppeared: Bool = false
    private(set) var viewDidAppeared: Bool = false
    public var isDisplaying: Bool = false

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // MARK: - Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        TLLogging.log("\(self) did load")
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !viewWillAppeared {
            viewWillAppeared = true
            self.viewWillFirstAppear()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TLLogging.log("\(self) did appear")
        isDisplaying = true
        if !viewDidAppeared {
            viewDidAppeared = true
            self.viewDidFirstAppear()
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        TLLogging.log("\(self) did disappear")
        isDisplaying = false
    }
    
    open func viewWillFirstAppear() {
        // nothing
    }
    
    open func viewDidFirstAppear() {
        // nothing
    }

    open func viewWillDisappearByInteractive() {
        // nothing
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
