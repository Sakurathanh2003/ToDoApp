//
//  TextViewExtension.swift
//  PhotoConverter2
//
//  Created by Linh Nguyen Duc on 23/12/2022.
//

import UIKit

public extension UITextView {
    func centerVerticalText() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect
        self.contentInset.top = topCorrect
    }
}
