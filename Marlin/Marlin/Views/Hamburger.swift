//
//  Hamburger.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI

struct Hamburger: ViewModifier {
    @Binding var menuOpen: Bool
    
    func body(content: Content) -> some View {
        
        content.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        Metrics.shared.sideNavigationView()
                        menuOpen.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .imageScale(.large)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                    .padding([.top, .bottom], 10)
                    .padding([.trailing, .leading], 5)
                    .accessibilityElement()
                    .accessibilityLabel("Side Menu")
                }
            }
        }
    }
}
