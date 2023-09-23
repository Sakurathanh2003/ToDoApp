//
//  PermissionHelper.swift
//  Teleprompter
//
//  Created by Manh Nguyen Ngoc on 10/12/2021.
//

import UIKit
import Photos
import Speech
import MediaPlayer

final class PermissionHelper {
    func isAllowCameraPermission() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    func isAllowPhotoPermission() -> Bool {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return status == .authorized || status == .limited
        } else {
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
    }
    
    func isAllowMicroPermission() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
    
    func isAllowSFSpeechPermission() -> Bool {
        return SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    func isAllowMPMediaLibraryPermission() -> Bool {
        return MPMediaLibrary.authorizationStatus() == .authorized
    }
    
    func requestMicroPermission(completion: @escaping (_ granted: Bool, _ needOpenAppSetting: Bool) -> Void) {
        let previousStatus = AVAudioSession.sharedInstance().recordPermission
        AVAudioSession.sharedInstance().requestRecordPermission { status in
            DispatchQueue.main.async {
                completion(status, previousStatus == .denied)
            }
        }
    }

    func requestPhotoPermission(completion: @escaping (_ status: PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }

    func requestCameraPermission(completion: @escaping (_ granted: Bool, _ needOpenAppSetting: Bool) -> Void) {
        let previousStatus = AVCaptureDevice.authorizationStatus(for: .video)
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted, previousStatus == .denied)
            }
        }
    }
    
    func requestSFSpeechPermission(completion: @escaping (_ granted: Bool, _ needOpenAppSetting: Bool) -> Void) {
        let previousStatus = SFSpeechRecognizer.authorizationStatus()
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized, previousStatus == .denied)
            }
        }
    }
    
    func requestMPMediaLibraryPermission(completion: @escaping (_ granted: Bool, _ needOpenAppSetting: Bool) -> Void) {
        let previousStatus = MPMediaLibrary.authorizationStatus()
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized, previousStatus == .denied)
            }
        }
    }

    func needOpenSettingCameraPermission() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted
    }

    func needOpenSettingPhotoPermission() -> Bool {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }

        return status == .denied || status == .restricted
    }
    
    func needOpenSettingMPMediaLibraryPermission() -> Bool {
        return MPMediaLibrary.authorizationStatus() == .denied || MPMediaLibrary.authorizationStatus() == .restricted
    }
}

// MARK: - LocationManager
class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()
    private var locationManager: CLLocationManager = CLLocationManager()
    private var requestLocationAuthorizationCallback: ((CLAuthorizationStatus) -> Void)?

    public func requestLocationAuthorization(completion: ((CLAuthorizationStatus) -> Void)?) {
        self.locationManager.delegate = self
        let currentStatus = CLLocationManager.authorizationStatus()
        guard currentStatus == .notDetermined else {
            completion?(currentStatus)
            return
        }

        if #available(iOS 13.4, *) {
            self.requestLocationAuthorizationCallback = { status in
                if status == .authorizedWhenInUse {
                    self.locationManager.requestAlwaysAuthorization()
                } else {
                    completion?(status)
                }
            }
            
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.requestLocationAuthorizationCallback?(status)
    }
}
