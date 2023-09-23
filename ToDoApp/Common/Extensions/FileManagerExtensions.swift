//
//  FileManagerExtensions.swift
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation

public extension FileManager {
    static func audioCollectionURL() -> URL {
        let url = self.documentURL().appendingPathComponent("Audios")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    
    static func imageMoneyTypeURL() -> URL {
        let url = self.documentURL().appendingPathComponent("ImageMoneyType")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    
    static func imageMoneyURL() -> URL {
        let url = self.documentURL().appendingPathComponent("ImageMoneyURL")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}

public extension FileManager {
    static func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }

    static func userPath() -> String {
        var documentURL = self.documentURL()
        documentURL.deleteLastPathComponent()
        return documentURL.path
    }

    static func documentURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }

    static func temporaryURL() -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func cacheURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last!
    }

    static func videoLivePhotoRequestedFolder() -> String {
        let path = NSTemporaryDirectory() + "VideoLivePhotoRequested"
        Self.createDirIfNeeded(path: path)
        return path
    }

    static func createDirIfNeeded(path: String) {
        var isDirectoryOutput: ObjCBool = false
        let pointer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        pointer.initialize(from: &isDirectoryOutput, count: 1)

        if FileManager.default.fileExists(atPath: path, isDirectory: pointer) == false || isDirectoryOutput.boolValue == false {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
    }
}
