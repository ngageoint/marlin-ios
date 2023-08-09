//
//  DataSourceSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import Foundation
import SwiftUI

protocol DataSourceSummaryView: View {
    var showBookmarkNotes: Bool { get set }
    var showMoreDetails: Bool { get set }
    var showTitle: Bool { get set }
    var showSectionHeader: Bool { get set }
}

extension View where Self: DataSourceSummaryView {
    func setShowMoreDetails(_ showMoreDetails: Bool) -> some DataSourceSummaryView {
        var newView = self
        newView.showMoreDetails = showMoreDetails
        return newView
    }
    func setShowTitle(_ showTitle: Bool) -> some DataSourceSummaryView {
        var newView = self
        newView.showTitle = showTitle
        return newView
    }
    func setShowSectionHeader(_ showSectionHeader: Bool) -> some DataSourceSummaryView {
        var newView = self
        newView.showSectionHeader = showSectionHeader
        return newView
    }
    func showBookmarkNotes(_ showBookmarkNotes: Bool) -> some DataSourceSummaryView {
        var newView = self
        newView.showBookmarkNotes = showBookmarkNotes
        return newView
    }
    
    @ViewBuilder
    func bookmarkNotesView(_ bookmarkable: Bookmarkable?) -> some View {
        if let bookmarkable = bookmarkable, showBookmarkNotes {
            BookmarkNotes(itemKey: bookmarkable.itemKey, dataSource: bookmarkable.key)
        }
    }
}
