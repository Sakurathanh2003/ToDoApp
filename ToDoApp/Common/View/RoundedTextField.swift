//
//  RoundedTextField.swift
//  StickmanAnimation
//
//  Created by Thanh Vu on 23/02/2023.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class RoundedTextFieldSubscriber {
    fileprivate var didChangeText = PublishSubject<String>()

    var text: Observable<String> {
        return self.didChangeText.asObservable()
    }
}

private struct Const {
    static let leftClearAnchorConstantDefault = 10.0
}

final class RoundedTextField: UIView {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var leftClearAnchor: NSLayoutConstraint!

    private let disposeBag = DisposeBag()
    let subscriber = RoundedTextFieldSubscriber()

    var text: String? {
        get { self.textField.text }
        set { self.textField.text = newValue }
    }

    func configEvent() {
        clearButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.subscriber.didChangeText.onNext("")
                self.textField.text = ""
                self.clearButton.isHidden = true
                self.updateLeftClearAnchor()
                self.textField.becomeFirstResponder()
            }).disposed(by: self.disposeBag)

        textField.rx.value.changed
            .subscribe(onNext: { [unowned self] value in
                let text = value ?? ""
                self.subscriber.didChangeText.onNext(text)
                self.clearButton.isHidden = text.isEmpty
                self.updateLeftClearAnchor()
            }).disposed(by: self.disposeBag)
    }
    
    private func updateLeftClearAnchor() {
        if clearButton.isHidden {
            self.leftClearAnchor.constant = -self.clearButton.bounds.width
        } else {
            self.leftClearAnchor.constant = Const.leftClearAnchorConstantDefault
        }
    }
}
