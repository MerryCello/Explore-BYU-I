//
//  ContentView.swift
//  Explore BYU-I
//
//  Created by Hannah Foniciello on 1/25/20.
//  Copyright © 2020 Kevin Foniciello. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var torchOn : Bool = false
    @State var labelDescriptions = LabelDescriptions()

    var aSmartCameraView : SmartCameraView!
    @ObservedObject var recognitionListener: VisionObjectRecognitionViewController

    var body: some View {
        ZStack {
            self.aSmartCameraView
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    TorchButton(torchIsOn: $torchOn)
                }
            }

            if recognitionListener.hasRecognized() {
                DescriptionPopup(
                    torchIsOn:   $torchOn,
                    smartCamera: recognitionListener,//.animation(),
                    description: self.labelDescriptions.get(label: self.recognitionListener.getIdentifier())
                ).transition(AnyTransition.scale.combined(with: .opacity))
                 .edgesIgnoringSafeArea(.top)
            }
        }
    }
    
    init() {
        aSmartCameraView = SmartCameraView()
        recognitionListener = aSmartCameraView.getSmartCameraVC()
        Torch.toggleOff()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
