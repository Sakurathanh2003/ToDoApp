//
//  AnimationableButton.swift
//  VO-VoiceChange
//
//  Created by Manh Nguyen Ngoc on 07/01/2022.
//

import UIKit

class AnimationableButton: UIButton {
    
    @IBInspectable var timeInterval: Double = 0.1
    @IBInspectable var minSizeScale: Double = 0.8
    
    private var tranformButton: CGAffineTransform!
    private var timer: Timer?
    private var runTime: Double = 0.8
    private var scaleValue: Double = 0.05
    
    func configTranform() {
        tranformButton = self.transform
    }
    
    func getNewTransform(view: CGAffineTransform, sizeScale: CGFloat) -> CGAffineTransform {
        return view.scaledBy(x: sizeScale, y: sizeScale)
    }
    
    func startAnimation() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.runTime += self.scaleValue
            
            if 1 <= self.runTime && self.runTime <= 1 / self.minSizeScale {
                self.transform = self.getNewTransform(view: self.tranformButton, sizeScale: CGFloat(1 / self.runTime))
            } else if self.minSizeScale <= self.runTime && self.runTime <= 1 {
                self.transform = self.getNewTransform(view: self.tranformButton, sizeScale: CGFloat(self.runTime))
            } else {
                self.scaleValue = -self.scaleValue
            }
        }
    }
    
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}
