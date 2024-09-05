//
//  MoreDetailsButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct MoreDetailsButton: View {
    var action: Action
    var body: some View {
        Button(action: action.action) {
            Text("More Details")
                .foregroundColor(Color.primaryColorVariant)
        }
        .accessibilityElement()
        .accessibilityLabel("More Details")
    }
}
