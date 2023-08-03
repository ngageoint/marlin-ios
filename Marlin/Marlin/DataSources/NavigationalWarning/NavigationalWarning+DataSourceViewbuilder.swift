//
//  NavigationalWarning+DataSourceViewbuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension NavigationalWarning: DataSourceViewBuilder {
//    typealias Summary = NavigationalWarningSummaryView
    var itemTitle: String {
        return "\(self.navAreaName) \(String(self.msgNumber))/\(String(self.msgYear)) (\(self.subregion ?? ""))"
    }
    var detailView: AnyView {
        AnyView(NavigationalWarningDetailView(navigationalWarning: self))
    }
    
//    func summaryView() -> some DataSourceSummaryView {
//        NavigationalWarningSummaryView(navigationalWarning: self)
//    }
    
    var summary: some DataSourceSummaryView {
        NavigationalWarningSummaryView(navigationalWarning: self)
    }
}
