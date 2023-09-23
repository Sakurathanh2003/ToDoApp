//
//  PhotoLibraryObserver.swift
//  StickmanAnimation
//
//  Created by Mei Mei on 13/04/2023.
//

import UIKit
import Photos
import RxSwift

class PhotoLibraryObserver: NSObject {
    var didChange = PublishSubject<()>()

    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension PhotoLibraryObserver: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.didChange.onNext(())
        }
    }
}
