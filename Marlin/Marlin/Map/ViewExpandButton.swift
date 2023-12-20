//
//  ViewExpandButton.swift
//  Marlin
//
//  Created by Daniel Barela on 5/16/23.
//

import SwiftUI

struct ViewExpandButton: View {
    @State var imageName: String = "fullscreen"
    @Binding var expanded: Bool
    
    var body: some View {
        Button(
            action: {
                buttonPressed()
            },
            label: {
                Label(
                    title: {},
                    icon: { Image(imageName)
                            .renderingMode(.template)
                    })
            }
        )
        .accessibilityElement()
        .accessibilityLabel("\(expanded ? "Expanded" : "Collapsed")")
        .onAppear {
            setButtonImage()
        }
        .onChange(of: expanded) { _ in
            setButtonImage()
        }
        .buttonStyle(
            MaterialFloatingButtonStyle(
                type: .secondary,
                size: .mini,
                foregroundColor: Color.primaryColorVariant,
                backgroundColor: Color.mapButtonColor
            )
        )
    }
    
    func buttonPressed() {
        withAnimation {
            expanded.toggle()
        }
    }
    
    func setButtonImage() {
        if expanded {
            imageName = "fullscreen_exit"
        } else {
            imageName = "fullscreen"
        }
    }
}
