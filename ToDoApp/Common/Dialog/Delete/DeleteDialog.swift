//
//  DeleteDialog.swift
//  MoneyManager
//
//  Created by MeiMei on 29/07/2023.
//

import UIKit
import RxSwift

class DeleteDialog: UIViewController {
    
    @IBOutlet weak var mainView: UIView!

    var observer: AnyObserver<()>?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if !self.mainView.bounds.contains(touches.first!.location(in: self.mainView)) {
            self.dismiss()
        }
    }
    
    func dismiss() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func cancelButtonDidTap(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func yesButtonDidTap(_ sender: UIButton) {
        observer?.onNext(())
        self.dismiss()
    }
}
