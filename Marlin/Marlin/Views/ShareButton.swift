//
//  ShareButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct ShareButton: View {
    var shareText: String
    var body: some View {
        Button(action: {
            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }) {
            Label(
                title: {},
                icon: { Image(systemName: "square.and.arrow.up")
                        .renderingMode(.template)
                        .foregroundColor(Color.primaryColorVariant)
                })
        }
        .accessibilityElement()
        .accessibilityLabel("share")
    }
}
