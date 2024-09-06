//
//  GeoPackageFeatureItemSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 4/11/23.
//

import SwiftUI

struct GeoPackageFeatureItemSummaryView: DataSourceSummaryView {
    @EnvironmentObject var router: MarlinRouter
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
            DataSourceActions(
                moreDetails: showMoreDetails 
                ? GeoPackageActions.Tap(featureItem: featureItem, path: $router.path)
                : nil,
                location: Actions.Location(latLng: featureItem.coordinate),
                zoom: GeoPackageActions.Zoom(latLng: featureItem.coordinate, itemKey: featureItem.itemKey),
                bookmark: Actions.Bookmark(
                    itemKey: featureItem.itemKey,
                    bookmarkViewModel: bookmarkViewModel
                )
            )
        }
        .onAppear {
            bookmarkViewModel.getBookmark(itemKey: featureItem.itemKey, dataSource: DataSources.geoPackage.key)
        }

    }
}
