//
//  FocusButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct FocusButton: View {
    var data: DataSource
    var body: some View {
        Button(
            action: {
                NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
                let notification = MapItemsTappedNotification(items: [data])
                NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
            },
            label: {
                Label(
                    title: {},
                    icon: { 
                        Image(systemName: "scope")
                            .renderingMode(.template)
                            .foregroundColor(Color.primaryColorVariant)
                    })
            }
        )
        .accessibilityElement()
        .accessibilityLabel("focus")
    }
}

struct FocusButton2: View {
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
