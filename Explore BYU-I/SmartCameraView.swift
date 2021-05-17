/*
 SmartCameraView.swift
 CameraClassifier

 Created by happyPenguinMac on 07/02/20.
 Copyright © 2020 Kevin Foniciello. All rights reserved.
 Abstract:
    UIViewControllerRepresentable for VisionObjectRecognitionViewController
*/

import SwiftUI

// Need UIViewControllerRepresentable to show any UIViewController in SwiftUI
struct SmartCameraView : UIViewControllerRepresentable {

    @ObservedObject var smartCameraViewController = VisionObjectRecognitionViewController()
    
    func getSmartCameraVC() -> VisionObjectRecognitionViewController {
        return self.smartCameraViewController
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SmartCameraView>)
        -> UIViewController {
        return smartCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<SmartCameraView>) {
        if (smartCameraViewController.hasRecognized()) {
            Torch.toggleOff()
        }
    }
}

