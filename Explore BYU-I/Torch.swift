//
//  torchToggler.swift
//  flashLight
//
//  Created by happyPenguinMac on 22/02/20.
//  Copyright © 2020 Kevin Foniciello. All rights reserved.
//

import AVFoundation

class Torch {
    
    class func toggle() -> Bool {
        var torchOn : Bool = false
        guard let device = AVCaptureDevice.default(for: .video) else { return torchOn }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                device.torchMode = (device.torchMode == .off ? .on : .off)
                torchOn = (device.torchMode == .on ? true : false)

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
                return false
            }
        } else {
            print("Torch is not available")
            return false
        }
        
        return torchOn
    }

    class func toggleOn() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                device.torchMode = .on

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
                return false
            }
        } else {
            print("Torch is not available")
            return false
        }
        
        return true
    }

    class func toggleOff() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                device.torchMode = .off

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
                return
            }
        } else {
            print("Torch is not available")
            return
        }
    }

    class func isOn() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }

        if device.hasTorch {
            return (device.torchMode == .on ? true : false)
        }
        
        return false
    }
}
