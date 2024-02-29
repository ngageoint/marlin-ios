//
//  FocusButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct FocusButton: View {
    var action: Action
    var body: some View {
        Button(action: action.action) {
            Label(
                title: {},
                icon: { Image(systemName: "scope")
                        .renderingMode(.template)
                        .foregroundColor(Color.primaryColorVariant)
                })
        }
        .accessibilityElement()
        .accessibilityLabel("focus")
    }
}
