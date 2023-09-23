//
//  CollectionViewExtensions.swift
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation
import UIKit

public extension UICollectionView {
    func registerCell<T>(type: T.Type, bundle: Bundle = Bundle.main) {
        let name = String(describing: type)
        self.register(UINib(nibName: name, bundle: bundle), forCellWithReuseIdentifier: name)
    }

    func registerHeader<T>(type: T.Type, bundle: Bundle = Bundle.main) {
        let name = String(describing: type)
        self.register(UINib(nibName: name, bundle: bundle), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: name)
    }

    func registerFooter<T>(type: T.Type, bundle: Bundle = Bundle.main) {
        let name = String(describing: type)
        self.register(UINib(nibName: name, bundle: bundle), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: name)
    }

    func dequeueCell<T>(type: T.Type, indexPath: IndexPath) -> T? {
        let name = String(describing: type)
        return self.dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as? T
    }

    func dequeueHeader<T>(type: T.Type, indexPath: IndexPath) -> T? {
        let name = String(describing: type)
        return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: name, for: indexPath) as? T
    }

    func dequeueFooter<T>(type: T.Type, indexPath: IndexPath) -> T? {
        let name = String(describing: type)
        return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: name, for: indexPath) as? T
    }
}
