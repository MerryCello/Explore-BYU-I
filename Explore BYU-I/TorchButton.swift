//
//  FlashButton.swift
//  CameraClassifier
//
//  Created by happyPenguinMac on 04/03/20.
//  Copyright © 2020 Kevin Foniciello. All rights reserved.
//

import SwiftUI

struct TorchButton: View {
    @Binding var torchIsOn: Bool
    var body: some View {
        Button(action: {
            self.torchIsOn = Torch.toggle()
        }) {
            Image(systemName: (self.torchIsOn ? "bolt.fill" : "bolt.slash.fill"))
                .padding()
                .font(.largeTitle)
                .foregroundColor(self.torchIsOn ? .yellow : .gray)
        }.padding()
    }
}

//struct FlashButton_Previews: PreviewProvider {
//    static var previews: some View {
//        TorchButton()
//    }
//}
