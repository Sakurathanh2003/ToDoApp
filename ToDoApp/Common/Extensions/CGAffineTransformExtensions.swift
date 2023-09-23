//
//  CGAffineTransformExtensions.swift
//  PhotoConverter2
//
//  Created by Linh Nguyen Duc on 21/12/2022.
//

import UIKit

extension CGAffineTransform {
    func translation() -> CGPoint {
        return CGPoint(x: self.tx, y: self.ty)
    }

    func scale() -> CGFloat {
        return sqrt(CGFloat(self.a * self.a + self.c * self.c))
    }

    func scaleX() -> CGFloat {
        return self.a
    }

    func scaleY() -> CGFloat {
        return self.d
    }

    func rotationAngle() -> CGFloat {
        return atan2(CGFloat(self.b), CGFloat(self.a))
    }
}
