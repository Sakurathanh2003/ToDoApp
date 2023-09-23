//
//  TableViewExtensions.swift
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation
import UIKit

public extension UITableView {
    func registerCell<T>(type: T.Type, bundle: Bundle = Bundle.main) {
        let name = String(describing: type)
        self.register(UINib(nibName: name, bundle: bundle), forCellReuseIdentifier: name)
    }

    func dequeueCell<T>(type: T.Type) -> T? {
        let name = String(describing: type)
        return self.dequeueReusableCell(withIdentifier: name) as? T
    }

    func dequeueCell<T>(type: T.Type, indexPath: IndexPath) -> T? {
        let name = String(describing: type)
        return self.dequeueReusableCell(withIdentifier: name, for: indexPath) as? T
    }
}
