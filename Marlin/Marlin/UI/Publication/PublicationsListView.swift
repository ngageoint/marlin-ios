//
//  PublicationsListView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
import SwiftUI

struct PublicationsListView: View {
    var key: String
    var publications: [PublicationModel]

    var body: some View {
        List {
            ForEach(publications) { epub in
                PublicationSummaryView(s3Key: epub.s3Key ?? "")
                    .setShowSectionHeader(false)
                    .setShowMoreDetails(false)
                    .setShowTitle(true)
                    .padding([.top, .bottom], 16)
            }
        }
        .background(Color.backgroundColor)
        .listRowBackground(Color.surfaceColor)
        .listStyle(.plain)
        .navigationTitle(key)
        .navigationBarTitleDisplayMode(.inline)
    }
}
