//
//  NavigationalWarning+DataSourceViewbuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension NavigationalWarning: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.navAreaName) \(String(self.msgNumber))/\(String(self.msgYear)) (\(self.subregion ?? ""))"
    }
    var detailView: AnyView {
        AnyView(NavigationalWarningDetailView(navigationalWarning: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false, mapName: String? = nil, showTitle: Bool = true) -> AnyView {
        AnyView(NavigationalWarningSummaryView(navigationalWarning: self, showMoreDetails: showMoreDetails, mapName: mapName, showTitle: showTitle))
    }
}
