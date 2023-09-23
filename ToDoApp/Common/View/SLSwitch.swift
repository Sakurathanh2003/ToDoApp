//
//  SLSwitch.swift
//  StickmanAnimation
//
//  Created by Thanh Vu on 19/04/2023.
//

import UIKit
import RxSwift

class SLSwitchSubscriber {
    fileprivate var didChange = PublishSubject<Bool>()
    
    var isOn: Observable<Bool> {
        return didChange.asObserver()
    }
}

@IBDesignable
class SLSwitch: TapableView {
    @IBInspectable var circleColor: UIColor = .white
    @IBInspectable var topCircleMargin: CGFloat = 2.0
    @IBInspectable var bottomCircleMargin: CGFloat = 2.0
    @IBInspectable var defaultLeftCircleMargin: CGFloat = 2.0
    @IBInspectable var defaultRightCircleMargin: CGFloat = 2.0
    
    @IBInspectable var selectedBackgroundColor: UIColor = .white
    @IBInspectable var unselectedBackgroundColor: UIColor = .white
    
    private var circleView: UIView!
    private var leftCircleMargin: NSLayoutConstraint!
    private var disposeBag = DisposeBag()
    
    var subscriber = SLSwitchSubscriber()
    var isOn: Bool = true {
        didSet {
            subscriber.didChange.onNext(self.isOn)
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if circleView != nil {
            self.circleView.layoutIfNeeded()
            circleView.cornerRadius = circleView.bounds.width / 2
            self.cornerRadius = self.bounds.height / 2
        }
    }
    
    private func config() {
        configUI()
        configEvent()
    }
    
    private func configUI() {
        self.delayEventDuration = 0
        self.scaleOnHighlight = 1
        self.interactiveInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)

        circleView = UIView()
        circleView.backgroundColor = circleColor
        circleView.isUserInteractionEnabled = false
        self.addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        leftCircleMargin = circleView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        leftCircleMargin.isActive = true
        
        circleView.heightAnchor.constraint(equalToConstant: self.bounds.height - self.topCircleMargin - self.bottomCircleMargin).isActive = true
        circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor).isActive = true
        circleView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    private func configEvent() {
        self.rx.tap.subscribe(onNext: { [unowned self] in
            self.isOn.toggle()
        }).disposed(by: self.disposeBag)
    }
    
    private func updateUI() {
        if self.isOn {
            self.leftCircleMargin.constant = self.bounds.width - self.bounds.height + self.defaultRightCircleMargin
            self.backgroundColor = selectedBackgroundColor
        } else {
            self.leftCircleMargin.constant = self.defaultLeftCircleMargin
            self.backgroundColor = unselectedBackgroundColor
        }
        
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
    }
}
