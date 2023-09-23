//
//  AVAssetExtension.swift
//
//  Created by Le Toan on 9/10/20.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import AVFoundation
import UIKit

public extension AVAsset {
    var numberOfFrames: Int {
        return Int(Double(self.fps) * self.duration.seconds)
    }

    var fps: Float {
        guard let videoTrack = self.tracks(withMediaType: .video).first else {
            return 0
        }

        return videoTrack.nominalFrameRate
    }

    var thumbnailImage: UIImage {
        var image = UIImage()
        do {
            let imgGenerator = AVAssetImageGenerator(asset: self)
            let cgImage = try! imgGenerator.copyCGImage(at: .zero, actualTime: nil)
            image = UIImage.init(cgImage: cgImage, scale: 1, orientation: image.imageOrientation)
            image = image.resize(to: CGSize(width: 800, height: 800))
        }

        return image
    }
    
    func thumbnailImage(size: CGSize) -> UIImage? {
        var image = UIImage()
        do {
            let imgGenerator = AVAssetImageGenerator(asset: self)
            guard let cgImage = try? imgGenerator.copyCGImage(at: .zero, actualTime: nil) else { return nil }
            image = UIImage.init(cgImage: cgImage, scale: 1, orientation: image.imageOrientation)
            image = image.resize(to: size)
        }

        return image
    }

    func resolution() -> CGSize {
        guard let videoTrack = self.tracks(withMediaType: .video).first else {
            return .zero
        }

        let orientation = self.videoOrientation
        if orientation == .left || orientation == .right || orientation == .leftMirrored || orientation == .rightMirrored {
            return CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        }

        return videoTrack.naturalSize
    }

    var videoOrientation: UIImage.Orientation {
        guard let videoTrack = self.tracks(withMediaType: .video).first else {
            return .up
        }

        let transform = videoTrack.preferredTransform
        let videoAngleInDegree = radiansToDegrees(atan2(transform.b, transform.a))
        let scaleX = (transform.a/abs(transform.a)) * sqrt(pow(transform.a, 2) + pow(transform.c, 2))
        let scaleY = (transform.d/abs(transform.d)) * sqrt(pow(transform.b, 2) + pow(transform.d, 2))

        var orientation = UIImage.Orientation.up
        switch videoAngleInDegree {
            case 0:
                orientation = .up
            case 90:
                orientation = .right
            case 180:
                orientation = .down
            case -90:
                orientation = .left
            default:
                break
        }

        if scaleX == -1 {
        switch orientation {
            case .up:
                return .upMirrored
            case .down:
                return .downMirrored
            default:
                break
            }
        }

        return orientation
    }

    func trimming(mediaTypes: [AVMediaType] = [.video], from leftTime: TimeInterval, to rightTime: TimeInterval) -> AVAsset {
        let mutableComposition = AVMutableComposition()
        let startTime = CMTime(seconds: leftTime, preferredTimescale: self.duration.timescale)
        let endTime = CMTime(seconds: rightTime, preferredTimescale: self.duration.timescale)
        for track in self.tracks {
            if !mediaTypes.contains(track.mediaType) {
                continue
            }

            let compositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? compositionTrack?.insertTimeRange(CMTimeRange(start: startTime, end: endTime), of: track, at: .zero)
            compositionTrack?.preferredTransform = track.preferredTransform
        }

        return mutableComposition
    }

    private func radiansToDegrees(_ value: CGFloat) -> CGFloat {
        return value * 180 / CGFloat.pi
    }
}
