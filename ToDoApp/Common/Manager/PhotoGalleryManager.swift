//
//  PhotoGalleryManager.swift
//  PhotoConverter
//
//  Created by Manh Nguyen Ngoc on 15/04/2022.
//
// swiftlint:disable all

import UIKit
import Photos

enum MediaType: String {
    case photo = "photo"
    case video = "video"
}

class LibraryAlbum {
    var assetCollection: PHAssetCollection
    var albumName: String?
    var numberOfItem: Int
    var phAssets: [PHAsset]
    
    init() {
        self.assetCollection = PHAssetCollection()
        self.albumName = ""
        self.numberOfItem = 0
        self.phAssets = [PHAsset]()
    }
    
    internal init(assetCollection: PHAssetCollection, albumName: String? = nil, numberOfItem: Int, phAssets: [PHAsset]) {
        self.assetCollection = assetCollection
        self.albumName = albumName
        self.numberOfItem = numberOfItem
        self.phAssets = phAssets
    }
}

class PhotoGalleryManager {
    static func getPhotoInAlbum(_ album: PHAssetCollection? = nil) -> [PHAsset] {
        var listPhoto = [PHAsset]()
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        if let album = album {
            PHAsset.fetchAssets(in: album, options: fetchOptions).enumerateObjects { (asset, _, _) in
                listPhoto.append(asset)
            }
        } else {
            let albums = self.getAlbumGallery(hasSmartAlbum: true, type: .photo)
            var photoExists = [String: Bool]()
            for album in albums {
                PHAsset.fetchAssets(in: album.assetCollection, options: fetchOptions).enumerateObjects { (asset, _, _) in
                    if photoExists[asset.localIdentifier] == nil {
                        listPhoto.append(asset)
                        photoExists[asset.localIdentifier] = true
                    }
                }
            }
        }
        
        return listPhoto.reversed()
    }
    
    static func getVideoInAlbum(_ album: PHAssetCollection? = nil) -> [PHAsset] {
        var listVideo = [PHAsset]()
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let album = album {
            PHAsset.fetchAssets(in: album, options: fetchOptions).enumerateObjects { (asset, _, _) in
                listVideo.append(asset)
            }
        } else {
            let albums = self.getAlbumGallery(hasSmartAlbum: true, type: .video)
            var photoExists = [String: Bool]()
            for album in albums {
                PHAsset.fetchAssets(in: album.assetCollection, options: fetchOptions).enumerateObjects { (asset, _, _) in
                    if photoExists[asset.localIdentifier] == nil {
                        listVideo.append(asset)
                        photoExists[asset.localIdentifier] = true
                    }
                }
            }
        }
        
        return listVideo
    }
    
    static func fetchAssets(collection: PHAssetCollection, fetchOptions: PHFetchOptions, type: MediaType) -> [LibraryAlbum] {
        var data = [LibraryAlbum]()
        
        if PHAsset.fetchAssets(in: collection, options: fetchOptions).count > 0 {
            if type == .photo {
                let photos = self.getPhotoInAlbum(collection)
                data.append(LibraryAlbum(assetCollection: collection, albumName: collection.localizedTitle, numberOfItem: photos.count, phAssets: photos))
            } else {
                let videos = self.getVideoInAlbum(collection)
                data.append(LibraryAlbum(assetCollection: collection, albumName: collection.localizedTitle, numberOfItem: videos.count, phAssets: videos))
            }
        }
        
        return data
    }
    
    static func getAlbumGallery(hasSmartAlbum: Bool = true, type: MediaType) -> [LibraryAlbum] {
        let dispatchGroup = DispatchGroup()
        var data = [LibraryAlbum]()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", type == .photo ? PHAssetMediaType.image.rawValue : PHAssetMediaType.video.rawValue)
        
        dispatchGroup.enter()
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    if hasSmartAlbum {
                        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                        smartAlbums.enumerateObjects { (collection, _, _) in
                            data += self.fetchAssets(collection: collection, fetchOptions: fetchOptions, type: type)
                        }
                    }
                    
                    let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                    albums.enumerateObjects { (collection, _, _) in
                        if PHAsset.fetchAssets(in: collection, options: fetchOptions).count > 0 {
                            data += self.fetchAssets(collection: collection, fetchOptions: fetchOptions, type: type)
                        }
                    }
                }
                
                dispatchGroup.leave()
            }
        } else {
            if hasSmartAlbum {
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                smartAlbums.enumerateObjects { (collection, _, _) in
                    if PHAsset.fetchAssets(in: collection, options: fetchOptions).count > 0 {
                        data += self.fetchAssets(collection: collection, fetchOptions: fetchOptions, type: type)
                    }
                }
            }
            
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            albums.enumerateObjects { (collection, _, _) in
                if PHAsset.fetchAssets(in: collection, options: fetchOptions).count > 0 {
                    data += self.fetchAssets(collection: collection, fetchOptions: fetchOptions, type: type)
                }
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.wait()
        return data
    }
}
