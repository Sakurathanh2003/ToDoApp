//
//  TwoStateImageView.swift
//  PhotoConverter2
//
//  Created by Linh Nguyen Duc on 01/12/2022.
//

import UIKit

class TwoStateImageView: UIImageView {
    @IBInspectable var selectedImage: UIImage?
    @IBInspectable var unselectedImage: UIImage?

    @IBInspectable var isSelected: Bool = false {
        didSet {
            self.refreshContent()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.refreshContent()
    }

    private func refreshContent() {
        self.image = self.isSelected ? self.selectedImage : self.unselectedImage
    }
}
