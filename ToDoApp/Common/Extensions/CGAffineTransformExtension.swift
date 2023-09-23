//
//  CGAffineTransformExtension.swift
//  PhotoConverter
//
//  Created by Manh Nguyen Ngoc on 09/05/2022.
//

import UIKit

public extension CGAffineTransform {
    var xScale: CGFloat {
        return sqrt(self.a * self.a + self.c * self.c)
    }

    var yScale: CGFloat {
        return sqrt(self.b * self.b + self.d * self.d)
    }

    var rotation: CGFloat {
        return CGFloat(atan2(Double(self.b), Double(self.a)))
    }

    var xOffset: CGFloat {
        return self.tx
    }

    var yOffset: CGFloat {
        return self.ty
    }
}
