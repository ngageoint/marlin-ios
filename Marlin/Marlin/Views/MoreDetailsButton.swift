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
        Button(action: {
            NotificationCenter.default.post(name: .ViewDataSource, object: ViewDataSource(dataSource: data))
        }) {
            Text("More Details")
                .foregroundColor(Color.primaryColorVariant)
        }
        .accessibilityElement()
        .accessibilityLabel("More Details")
    }
}
