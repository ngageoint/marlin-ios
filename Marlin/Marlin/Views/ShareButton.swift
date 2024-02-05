//
//  ShareButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct ShareButton: View {
    var shareText: String
    var dataSource: (any DataSource)?
    var body: some View {
        
        if let dataSource = dataSource {
            ShareLink(
                item: shareText,
                subject: Text(dataSource.itemTitle),
                message: Text(dataSource.itemTitle)
            ) {
                Label(
                    title: {},
                    icon: { Image(systemName: "square.and.arrow.up")
                            .renderingMode(.template)
                            .foregroundColor(Color.primaryColorVariant)
                    })
            }
            .accessibilityElement()
            .accessibilityLabel("share")
        } else {
            ShareLink(item: shareText) {
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
}
