//
//  AudioManager.swift
//  TrumpVoiceChange
//
//  Created by Manh Nguyen Ngoc on 11/19/22.
//

import Foundation
import PhotosUI
import Photos

class AlbumHelper {
    
    static let albumName = "TimeStampAlbum"
    static let sharedInstance = AlbumHelper()

    var assetCollection: PHAssetCollection!

    init() {
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", AlbumHelper.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            if let firstObject = collection.firstObject {
                return firstObject
            }

            return nil
        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: AlbumHelper.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }

    func saveVideoToAlbum(mediaType: AVMediaType, videoURL: URL) {
        if mediaType != .video {
            print("File is not video type!")
            return
        }
        
        if assetCollection == nil {
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            let assetPlaceholder = assetChangeRequest?.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder] as NSFastEnumeration)}, completionHandler: nil)
    }
    
    func saveVideoToAlbum(videoURL: URL) {
        if assetCollection == nil {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            let assetPlaceholder = assetChangeRequest?.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder] as NSFastEnumeration)}, completionHandler: nil)
    }
}
