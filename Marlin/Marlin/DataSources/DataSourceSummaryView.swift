//
//  DataSourceSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import Foundation
import SwiftUI

protocol DataSourceSummaryView: View {
    var bookmark: Bookmark? { get set }
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
    func setBookmark(_ bookmark: Bookmark?) -> some DataSourceSummaryView {
        var newView = self
        newView.bookmark = bookmark
        return newView
    }
}
