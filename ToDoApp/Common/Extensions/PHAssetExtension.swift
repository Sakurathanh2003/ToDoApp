//
//  PHAssetExtension.swift
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation
import Photos
import UIKit
import MobileCoreServices
import RxSwift

public extension PHAsset {
    func thumbnail(size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true

        var result: UIImage?
        PHImageManager.default().requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: option) {(image, _) in
            result = image
        }

        return result
    }

    func getUIImage(completeHandler: @escaping(_ image: UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .current
        options.isSynchronous = false
        manager.requestImageData(for: self, options: options) { data, _, _, _ in

            if let data = data, let img = UIImage(data: data) {
                completeHandler(img)
            } else {
                completeHandler(nil)
            }
        }
    }

    func thumbnail(maxSize: CGFloat) -> UIImage? {
        let ratio = CGFloat(self.pixelWidth) / CGFloat(self.pixelHeight)
        let targetSize: CGSize
        if ratio < 1 {
            targetSize = CGSize(width: maxSize * ratio, height: maxSize)
        } else {
            targetSize = CGSize(width: maxSize, height: maxSize / ratio)
        }

        return self.thumbnail(size: targetSize)
    }

    func thumbnail(minSize: CGFloat) -> UIImage? {
        let ratio = CGFloat(self.pixelWidth) / CGFloat(self.pixelHeight)
        let targetSize: CGSize
        if ratio > 1 {
            targetSize = CGSize(width: minSize * ratio, height: minSize)
        } else {
            targetSize = CGSize(width: minSize, height: minSize / ratio)
        }

        return self.thumbnail(size: targetSize)
    }

    func originalFileName() -> String? {
        if let resource = PHAssetResource.assetResources(for: self).first {
            return resource.originalFilename
        }

        return nil
    }

    static func fromLocalIdentifier(_ id: String) -> PHAsset? {
        let options = PHFetchOptions()
        options.fetchLimit = 1
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: options)
        return result.firstObject
    }

    func isGifType() -> Bool {
        if let identifier = self.value(forKey: "uniformTypeIdentifier") as? String {
            if identifier == UTType.gif.identifier {
               return true
             }
        }

        return false
    }

    func getVideoLivePhotoURL(targetSize: CGSize = CGSize(width: 300, height: 300)) -> URL? {
        if self.mediaSubtypes != .photoLive {
            return nil
        }

        let semaphore = DispatchSemaphore(value: 0)

        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .fastFormat
        options.version = .current
        options.isNetworkAccessAllowed = true
        var resultURL: URL?
        PHImageManager.default().requestLivePhoto(for: self, targetSize: targetSize, contentMode: .default, options: options) { livePhoto, _ in
            guard let livePhoto = livePhoto else {
                semaphore.signal()
                return
            }

            guard let videoResource = PHAssetResource.assetResources(for: livePhoto).first(where: {$0.type == .pairedVideo}) else {
                semaphore.signal()
                return
            }

            let filePath = FileManager.videoLivePhotoRequestedFolder() + "/" + videoResource.originalFilename
            let fileURL = URL(fileURLWithPath: filePath)
            if FileManager.default.fileExists(atPath: filePath) {
                resultURL = fileURL
                semaphore.signal()
                return
            }

            let assetResourceRequestOptions = PHAssetResourceRequestOptions()
            assetResourceRequestOptions.isNetworkAccessAllowed = true
            PHAssetResourceManager.default().writeData(for: videoResource, toFile: fileURL, options: assetResourceRequestOptions) { error in
                if let error = error {
                    print(error)
                } else {
                    resultURL = fileURL
                }

                semaphore.signal()
            }
        }

        semaphore.wait()
        return resultURL
    }

    func getAVAsset() -> AVAsset? {
        let semaphore = DispatchSemaphore(value: 0)
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = .mediumQualityFormat

        var result: AVAsset?
        PHCachingImageManager().requestAVAsset(forVideo: self, options: options) { (avAsset, _, _) in
            result = avAsset
            semaphore.signal()
        }

        semaphore.wait()
        return result
    }

    func getImage() -> UIImage? {
        if let data = self.getImageData() {
            return UIImage(data: data)?.fixImageOrientation()
        }

        return nil
    }

    func getImageData() -> Data? {
        let semaphore = DispatchSemaphore(value: 0)
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true

        var result: Data?
        if #available(iOS 13, *) {
            PHCachingImageManager().requestImageDataAndOrientation(for: self, options: options) { (imageData, _, _, _) in
                result = imageData
                semaphore.signal()
            }
        } else {
            PHCachingImageManager().requestImageData(for: self, options: options) { (imageData, _, _, _) in
                result = imageData
                semaphore.signal()
            }
        }

        semaphore.wait()
        return result
    }

    func imageMemorySize() -> Int? {
        guard self.mediaType == .image else {
            return nil
        }

        var resource: PHAssetResource?
        if self.mediaSubtypes.contains(.photoLive) == true {
            resource = PHAssetResource.assetResources(for: self).filter { $0.type == .pairedVideo }.first
        } else {
            resource = PHAssetResource.assetResources(for: self).filter { $0.type == .photo }.first
        }

        if let fileSize = resource?.value(forKey: "fileSize") as? Int {
            return fileSize
        }

        return nil
    }

    func fileExtension() -> String? {
        guard let filename = self.value(forKey: "filename") as? String else {
            return nil
        }

        return filename.components(separatedBy: ".").last
    }

    func fetchImage() -> Observable<UIImage?> {
        return Observable<UIImage?>.create { observer in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true

            if #available(iOS 13, *) {
                PHCachingImageManager().requestImageDataAndOrientation(for: self, options: options) { (imageData, _, _, _) in
                    if let data = imageData {
                        let image = UIImage(data: data)
                        observer.onNext(image)
                    } else {
                        observer.onNext(nil)
                    }

                    observer.onCompleted()
                }
            } else {
                PHCachingImageManager().requestImageData(for: self, options: options) { (imageData, _, _, _) in
                    if let data = imageData {
                        let image = UIImage(data: data)
                        observer.onNext(image)
                    } else {
                        observer.onNext(nil)
                    }

                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    func fetchAVAsset() -> Observable<AVAsset?> {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = .highQualityFormat

        return Observable<AVAsset?>.create { observer in
            PHCachingImageManager().requestAVAsset(forVideo: self, options: options) { (avAsset, _, _) in
                observer.onNext(avAsset)
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    func getExtension() -> String {
        if let identifier = self.value(forKey: "uniformTypeIdentifier") as? String {
            switch identifier as CFString {
            case kUTTypePNG:
                return "PNG"
            case kUTTypeJPEG:
                return "JPG"
            default:
                break
            }
        }

        return "JPG"
    }
}
