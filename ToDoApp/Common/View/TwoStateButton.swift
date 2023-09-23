//
//  TwoStateButton.swift
//  StickmanAnimation
//
//  Created by Mei Mei on 14/03/2023.
//

import UIKit

class TwoStateButton: UIButton {
    @IBInspectable var selectedImage: UIImage?
    @IBInspectable var unselectedImage: UIImage?

    @IBInspectable var isAllowedInteraction: Bool = false {
        didSet {
            self.refreshContent()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.refreshContent()
    }

    private func refreshContent() {
        self.setImage(self.isAllowedInteraction ? self.selectedImage : self.unselectedImage, for: .normal)
        self.isUserInteractionEnabled = isAllowedInteraction
    }
}
