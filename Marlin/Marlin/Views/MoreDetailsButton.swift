//
//  MoreDetailsButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct MoreDetailsButton: View {
    var data: DataSource

    var body: some View {
        Button(
            action: {
                NotificationCenter.default.post(name: .ViewDataSource, object: ViewDataSource(dataSource: data))
            },
            label: {
                Text("More Details")
                    .foregroundColor(Color.primaryColorVariant)
            }
        )
        .accessibilityElement()
        .accessibilityLabel("More Details")
    }
}

struct MoreDetailsButton2: View {
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
