//
//  Popup.swift
//  Popup
//
//  Created by happyPenguinMac on 24/02/20.
//  Copyright © 2020 Kevin Foniciello. All rights reserved.
//

import SwiftUI

struct DescriptionPopup: View {
    @Binding var torchIsOn: Bool
    @ObservedObject var smartCamera: VisionObjectRecognitionViewController
    var headline: String
    var subheadline: String
    var description: String
    
    let headlinePadding    = EdgeInsets(top: 10, leading:  5, bottom:  0, trailing:  5)
    let subHeadlinePadding = EdgeInsets(top:  0, leading:  5, bottom: 10, trailing:  5)
    let bodyPadding        = EdgeInsets(top:  0, leading: 10, bottom: 20, trailing: 10)
    
    var body: some View {
        let hide = TapGesture().onEnded { _ in
            self.smartCamera.setIsRecognized(false)
            self.torchIsOn = false
        }
        let doNothing = TapGesture().onEnded { _ in }
        let popup = ZStack {
            BlurView(style: .light).transition(AnyTransition.move(edge: .top))
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    GeometryReader { geometry in
                        VStack {
                            Text("\(self.headline)")
                                .padding(self.headlinePadding)
                                .font(.headline)
                            Text("\(self.subheadline)")
                                .padding(self.subHeadlinePadding)
                                .font(.subheadline)
                            ScrollView {
                                VStack {
                                    Text("\(self.description)")
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(self.bodyPadding)
                                        .font(.body)
                                }
                            }
                        }
                        .frame(width: geometry.size.width - 10, height: geometry.size.height * 0.66, alignment: .center)
                        .foregroundColor(.black)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(40)
                        .gesture(doNothing)
                        Spacer()
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding(.top)
        .gesture(hide)
        
        return popup
    }
    
    init(torchIsOn: Binding<Bool>,
         smartCamera: VisionObjectRecognitionViewController,
         description: Description) {
        
        self._torchIsOn = torchIsOn
        self.smartCamera = smartCamera
        self.headline = description.headline
        self.subheadline = description.subheadline
        self.description = description.body
        Torch.toggleOff()
    }
}
