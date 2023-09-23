//
//  UIImageExtensions.swift
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation
import UIKit
// swiftlint:disable all

public extension UIImage {
    static func getImagesFromGifData(_ data: Data) -> [UIImage] {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return [] }
        let frameCount = CGImageSourceGetCount(imageSource)
        var frames = [UIImage]()

        for index in 0..<frameCount {
            if let imageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                let image = UIImage(cgImage: imageRef)
                frames.append(image)
            }
        }

        return frames
    }
    
    static func firstFrameFrom(gifURL: URL) -> UIImage? {
        guard let imageData = try? Data(contentsOf: gifURL) else {
            return nil
        }
        
        return self.getFirstFrameOfGifData(imageData)
    }

    static func getFirstFrameOfGifData(_ data: Data) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(imageSource)
        if frameCount == 0 {
            return nil
        }

        if let imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
            return UIImage(cgImage: imageRef)
        }

        return nil
    }

    func resize(to size: CGSize, shouldAntiliasing: Bool = true) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(shouldAntiliasing)
        draw(in: CGRect(origin: CGPoint.zero, size:size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }

    func crop(rect: CGRect) -> UIImage {
        guard let cgImage = self.cgImage else {
            return self
        }
        guard let cropImage = cgImage.cropping(to: rect) else {
            return self
        }
        return UIImage.init(cgImage: cropImage) 
    }

    func fixImageOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }

        return self.reRenderImage()
    }

    func reRenderImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect.init(origin: .zero, size: size))
        let normalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalImage ?? self
    }

    func resizeToFit(size: CGSize, scale: CGFloat = 1) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)

        var targetRect = CGRect.zero
        if size.width / self.size.width * self.size.height <= size.height {
            targetRect.size = CGSize(width: size.width, height: size.width / self.size.width * self.size.height)
        } else {
            targetRect.size = CGSize(width: size.height / self.size.height * self.size.width, height: size.height)
        }

        targetRect.origin.x = (size.width - targetRect.width)/2
        targetRect.origin.y = (size.height - targetRect.height)/2

        UIColor.white.setFill()
        UIGraphicsGetCurrentContext()?.fill([CGRect(x: 0, y: 0, width: size.width, height: size.height)])
        self.draw(in: targetRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizeToFit(maxSize: CGFloat) -> UIImage {
        if self.size.width < maxSize && self.size.height < maxSize {
            return self
        }
        
        let originSizeRatio = self.size.width/self.size.height
        var targetSize: CGSize
        
        if self.size.width < self.size.height {
            let height = CGFloat.minimum(maxSize, self.size.height)
            targetSize = CGSize(width: height * originSizeRatio, height: height)
        } else {
            let width = CGFloat.minimum(maxSize, self.size.width)
            targetSize = CGSize(width: width, height: width/originSizeRatio)
        }
        
        return self.resize(to: targetSize)
    }
    
    func resizeToFit(minSize: CGFloat) -> UIImage {
        if self.size.width < minSize && self.size.height < minSize {
            return self
        }
        
        let originSizeRatio = self.size.width/self.size.height
        var targetSize: CGSize
        
        if self.size.width < self.size.height {
            let width = CGFloat.minimum(minSize, self.size.width)
            targetSize = CGSize(width: width, height: width/originSizeRatio)
        } else {
            let height = CGFloat.minimum(minSize, self.size.height)
            targetSize = CGSize(width: height * originSizeRatio, height: height)
        }
        
        return self.resize(to: targetSize)
    }
    
    func generateThumbnail() -> UIImage {
        let maxSize: CGFloat = 800
        
        return resizeToFit(maxSize: maxSize)
    }
    
    func makeSquareImage(withBackgroundColor bgColor: UIColor) -> UIImage {
        let size = CGFloat.maximum(self.size.width, self.size.height)
        let contextSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContext(contextSize)
        bgColor.setFill()
        let context = UIGraphicsGetCurrentContext()
        context?.fill(CGRect(origin: .zero, size: contextSize))
        
        let drawLocation = CGPoint(x: (contextSize.width - self.size.width)/2, y: (contextSize.height - self.size.height)/2)
        self.draw(at: drawLocation)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

public extension UIImage {
    func merge(in viewSize: CGSize, with imageTuples: [(image: UIImage, viewSize: CGSize, transform: CGAffineTransform)]) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.scaleBy(x: size.width / viewSize.width, y: size.height / viewSize.height)

        draw(in: CGRect(origin: .zero, size: viewSize), blendMode: .normal, alpha: 1)

        for imageTuple in imageTuples {
            let areaRect = CGRect(origin: .zero, size: imageTuple.viewSize)

            context.saveGState()
            context.concatenate(imageTuple.transform)

            context.setBlendMode(.color)
            UIColor.clear.setFill()
            context.fill(areaRect)

            imageTuple.image.draw(in: areaRect, blendMode: .normal, alpha: 1)

            context.restoreGState()
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

public extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return UIImage()
        }
    }

}

public extension UIImage {
    convenience init?(named name: String, in bundle: Bundle?) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
}

extension UIImage {
    func fetchCIImage() -> CIImage {
        var ciImage: CIImage
        if let ciImageNonnull = self.ciImage {
            ciImage = ciImageNonnull
        } else {
            ciImage = CIImage(cgImage: self.cgImage!)
        }

        return ciImage
    }

    func flipHorizontally() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image {
            let context = $0.cgContext
            context.translateBy(x: size.width / 2, y: size.height / 2)
            context.scaleBy(x: -1, y: 1)
            context.translateBy(x: -size.width / 2, y: -size.height / 2)
            draw(at: .zero)
        }
    }

    func padding(_ padding: CGFloat, fillColor: UIColor? = nil) -> UIImage {
        return self.padding(edgeInset: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding), fillColor: fillColor)
    }

    func padding(edgeInset: UIEdgeInsets, fillColor: UIColor? = nil) -> UIImage {
        let newSize = CGSize(width: self.size.width + edgeInset.left + edgeInset.right, height: self.size.height + edgeInset.top + edgeInset.bottom)
        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)

        if let fillColor = fillColor {
            UIGraphicsGetCurrentContext()?.setFillColor(fillColor.cgColor)
            UIGraphicsGetCurrentContext()?.fill([CGRect(origin: .zero, size: newSize)])
        }

        self.draw(in: CGRect(x: edgeInset.left, y: edgeInset.top, width: self.size.width, height: self.size.height))

        let outputImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return outputImage
    }
}

