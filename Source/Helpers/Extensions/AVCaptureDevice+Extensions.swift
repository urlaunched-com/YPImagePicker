//
//  AVCaptureDevice+Extensions.swift
//
//  Created by Nik Kov on 23.04.2018.
//  Copyright © 2018 Octopepper. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    func tryToggleTorch() {
        guard hasFlash else {
            return
        }

        do {
            try lockForConfiguration()

            switch torchMode {
            case .auto:
                torchMode = .on
            case .on:
                torchMode = .off
            case .off:
                torchMode = .auto
            @unknown default:
                throw YPError.custom(message: "unknown default case")
            }

            unlockForConfiguration()
        } catch {
            ypLog("Error with torch \(error).")
        }
    }
}

internal extension AVCaptureDevice {
    class var audioCaptureDevice: AVCaptureDevice? {
        let availableMicrophoneAudioDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: .audio, position: .unspecified).devices
        return availableMicrophoneAudioDevices.first
    }

    /// Best available device for selected position.
    class func deviceForPosition(_ p: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devicesSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInTripleCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: p)
        let devices = devicesSession.devices
        guard !devices.isEmpty else {
            print("Don't have supported cameras for this position: \(p.rawValue)")
            return nil
        }

        if let wideAngleDevice = devices.first(where: { $0.deviceType == .builtInWideAngleCamera }) {
            return wideAngleDevice
        }

        return devices.first
    }

    class func deviceForPositionAndType(_ position: AVCaptureDevice.Position, type: AVCaptureDevice.DeviceType) -> AVCaptureDevice? {
        let devicesSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInTripleCamera, .builtInTrueDepthCamera], mediaType: .video, position: position)
        let devices = devicesSession.devices

        if let device = devices.first(where: { $0.deviceType == type }) {
            return device
        }

        if type == .builtInUltraWideCamera {
            if let device = devices.first(where: { $0.deviceType == .builtInTripleCamera || $0.deviceType == .builtInDualCamera }) {
                return device
            }
        }

        if type == .builtInTelephotoCamera {
            if let device = devices.first(where: { $0.deviceType == .builtInTripleCamera || $0.deviceType == .builtInDualCamera }) {
                return device
            }
        }

        return devices.first(where: { $0.deviceType == .builtInWideAngleCamera }) ?? devices.first
    }

    class func hasCamera(position: AVCaptureDevice.Position, type: AVCaptureDevice.DeviceType) -> Bool {
        let devicesSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInTripleCamera, .builtInTrueDepthCamera], mediaType: .video, position: position)
        let devices = devicesSession.devices

        if devices.contains(where: { $0.deviceType == type }) {
            return true
        }

        if type == .builtInUltraWideCamera || type == .builtInTelephotoCamera {
            return devices.contains(where: { $0.deviceType == .builtInTripleCamera || $0.deviceType == .builtInDualCamera })
        }

        return false
    }
}
