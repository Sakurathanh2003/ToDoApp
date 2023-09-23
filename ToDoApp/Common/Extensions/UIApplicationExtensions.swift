//
//  UIApplicationExtensions.swift
//  PhotoConverter2
//
//  Created by Linh Nguyen Duc on 02/12/2022.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        return self.windows.first(where: { $0.isKeyWindow })
    }
}
