//
//  PreviewCameraView.swift
//  PlantIdentification
//
//  Created by Manh Nguyen Ngoc on 10/09/2021.
//

import UIKit
import AVFoundation

class PreviewCameraView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return (layer as? AVCaptureVideoPreviewLayer)!
    }
}
