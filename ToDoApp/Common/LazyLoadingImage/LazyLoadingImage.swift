//
//  LazyLoadingImageView.swift
//
//
//  Created by Mei Mei on 28/09/2022.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import SDWebImage
import RxSwift

private class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<AnyObject, AnyObject>()

    func cacheImage(image: UIImage, key: String) {
        cache.setObject(image, forKey: key as AnyObject)
    }

    func getImage(key: String) -> UIImage? {
        return cache.object(forKey: key as AnyObject) as? UIImage
    }

    func removeAllObjects() {
        cache.removeAllObjects()
    }

    func removeObject(key: String) {
        cache.removeObject(forKey: key as AnyObject)
    }
}

class LazyLoadingImageView: UIImageView {
    private var key: String = ""

    @IBInspectable var isCachingEnabled: Bool = true {
        didSet {
            if !isCachingEnabled {
                ImageCache.shared.removeObject(key: key)
            }
        }
    }

    // MARK: - Load Image with URL
    func loadImageFromInternet(url: URL?) {
        guard let url else {
            return
        }

        if let imageFromCache = ImageCache.shared.getImage(key: url.absoluteString) {
            self.image = imageFromCache
            return
        }

        DispatchQueue.global().async {
            SDWebImageManager.shared.loadImage(with: url, progress: nil) { [weak self] newImage, _, _, _, _, _ in
                guard let self, let newImage else {
                    return
                }

                if self.isCachingEnabled {
                    ImageCache.shared.cacheImage(image: newImage, key: url.absoluteString)
                    self.key = url.absoluteString
                }

                DispatchQueue.main.async {
                    self.image = newImage
                }
            }
        }
    }

    func loadImage(imageURL: URL?, type: MediaType, maxSize: CGFloat? = nil) {
        guard let imageURL else {
            return
        }
        
        if let imageFromCache = ImageCache.shared.getImage(key: imageURL.absoluteString) {
            self.image = imageFromCache
            return
        }

        DispatchQueue.global().async {
            guard let newImage = self.getImageFromURL(url: imageURL, type: type) else {
                DispatchQueue.main.async {
                    self.image = nil
                }

                return
            }

            if let maxSize {
                let resizedImage = newImage.resizeToFit(maxSize: maxSize)
                if self.isCachingEnabled {
                    ImageCache.shared.cacheImage(image: resizedImage, key: imageURL.absoluteString)
                    self.key = imageURL.absoluteString
                }

                DispatchQueue.main.async {
                    self.image = resizedImage
                }

                return
            }

            if self.isCachingEnabled {
                ImageCache.shared.cacheImage(image: newImage, key: imageURL.absoluteString)
                self.key = imageURL.absoluteString
            }

            DispatchQueue.main.async {
                self.image = newImage
            }
        }
    }

    private func getImageFromURL(url: URL, type: MediaType) -> UIImage? {
        if type == .photo {
            return UIImage(contentsOfFile: url.path)
        }

        do {
            let asset = AVURLAsset(url: url , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 10), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)

            return thumbnail
        } catch {
            return nil
        }
    }

    // MARK: - Load Image with PHAsset
    func loadImage(phAsset: PHAsset?, maxSize: CGFloat? = nil) {
        guard let phAsset else {
            self.image = nil
            return
        }

        if let imageFromCache = ImageCache.shared.getImage(key: phAsset.localIdentifier) {
            self.image = imageFromCache
            return
        }

        DispatchQueue.global().async {
            guard let newImage = phAsset.thumbnail() else {
                DispatchQueue.main.async {
                    self.image = nil
                }

                return
            }

            if let maxSize {
                let resizedImage = newImage.resizeToFit(maxSize: maxSize)
                if self.isCachingEnabled {
                    ImageCache.shared.cacheImage(image: resizedImage, key: phAsset.localIdentifier)
                    self.key = phAsset.localIdentifier
                }

                DispatchQueue.main.async {
                    self.image = resizedImage
                }

                return
            }

            if self.isCachingEnabled {
                ImageCache.shared.cacheImage(image: newImage, key: phAsset.localIdentifier)
                self.key = phAsset.localIdentifier
            }

            DispatchQueue.main.async {
                self.image = newImage
            }
        }
    }

    func loadFullSizeImage(phAsset: PHAsset?) {
        guard let phAsset else {
            self.image = nil
            return
        }

        if let imageFromCache = ImageCache.shared.getImage(key: phAsset.localIdentifier) {
            self.image = imageFromCache
            return
        }

        phAsset.getUIImage { [weak self] newImage in
            guard let self, let newImage else {
                return
            }

            if self.isCachingEnabled {
                ImageCache.shared.cacheImage(image: newImage, key: phAsset.localIdentifier)
                self.key = phAsset.localIdentifier
            }

            DispatchQueue.main.async {
                self.image = newImage
            }
        }
    }
}
