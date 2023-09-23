//
//  CGSizeExtensions.swift
//  KiteVid
//
//  Created by Thanh Vu on 29/04/2021.
//  Copyright © 2021 Thanh Vu. All rights reserved.
//

import Foundation
import UIKit

public extension CGSize {
    func ratio() -> CGFloat {
        return self.width / self.height
    }

    func rounded(_ rule: FloatingPointRoundingRule) -> CGSize {
        return CGSize(width: self.width.rounded(rule), height: self.height.rounded(rule))
    }

    func rounded() -> CGSize {
        return CGSize(width: self.width.rounded(), height: self.height.rounded())
    }

    func pixelDescription() -> String {
        return "\(Int(self.width))px x \(Int(self.height))px"
    }

    func fitTo(boundingSize: CGSize) -> CGRect {
        var rect = CGRect.zero
        if boundingSize.height / self.height * self.width <= boundingSize.width {
            rect.size.height = boundingSize.height
            rect.size.width = boundingSize.height / self.height * self.width
        } else {
            rect.size.width = boundingSize.width
            rect.size.height = boundingSize.width / self.width * self.height
        }

        rect.origin.x = (boundingSize.width - rect.width) / 2
        rect.origin.y = (boundingSize.height - rect.height) / 2
        return rect
    }

    func reducing(maxResolution: CGSize) -> CGSize {
        if self.width <= maxResolution.width && self.height <= maxResolution.height {
            return self
        }

        var outputResolution = CGSize.zero
        if self.width/self.height > maxResolution.width/maxResolution.height {
            outputResolution.width = maxResolution.width
            outputResolution.height = outputResolution.width / self.width * self.height
        } else {
            outputResolution.height = maxResolution.height
            outputResolution.width = outputResolution.height / self.height * self.width
        }

        return outputResolution
    }
}
