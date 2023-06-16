//
//  OnboardingTabTemplate.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct OnboardingTabTemplate<M:View, T:View>: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?

    var title: String
    var explanation: String?
    var imageName: String?
    var systemImageName: String?
    var imageAreaContent: M?
    var buttons: T
    
    init(title: String, explanation: String? = nil, imageName: String? = nil, systemImageName: String? = nil, imageAreaContent: M? = EmptyView(), buttons: T) {
        self.title = title
        self.explanation = explanation
        self.imageName = imageName
        self.systemImageName = systemImageName
        self.imageAreaContent = imageAreaContent
        self.buttons = buttons
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .bottom) {
                VStack(alignment: .center, spacing: 16) {
                    Text(title)
                        .font(.headline4)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .opacity(0.94)
                    
                    if let explanation = explanation {
                        Text(explanation)
                            .font(.headline6)
                            .opacity(0.87)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            imageAreaContent
            if verticalSizeClass != .compact {
                if let imageName = imageName {
                    Image(imageName)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity)
                } else if let systemImageName = systemImageName {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(Color.black)
                        .frame(maxHeight: .infinity)
                }
            } else if imageAreaContent == nil || imageAreaContent is EmptyView {
                Spacer()
                    .frame(maxHeight: 24)
            }
            buttons
        }
        .padding(16)
        .frame(maxHeight: .infinity)
    }
}
