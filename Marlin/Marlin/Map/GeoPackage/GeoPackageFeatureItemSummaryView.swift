//
//  GeoPackageFeatureItemSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 4/11/23.
//

import SwiftUI

struct GeoPackageFeatureItemSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    
    var showMoreDetails: Bool = true
    
    var showTitle: Bool = false
    
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false
    var featureItem: GeoPackageFeatureItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let date = featureItem.dateString {
                Text(date)
                    .overline()
            }
            Text(featureItem.itemTitle)
                .primary()
            if let secondary = featureItem.secondaryTitle {
                Text(secondary)
                    .lineLimit(8)
                    .secondary()
            }
            Text(featureItem.layerName ?? "")
                .overline()
            bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
            DataSourceActionBar(data: featureItem, showMoreDetailsButton: true, showFocusButton: false)
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: featureItem.itemKey, dataSource: DataSources.geoPackage.key)
        }

    }
}
