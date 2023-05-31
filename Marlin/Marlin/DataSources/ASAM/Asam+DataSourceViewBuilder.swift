//
//  Asam+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Asam: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.hostility ?? "")\(self.hostility != nil && self.victim != nil ? ": " : "")\(self.victim ?? "")"
    }
    var detailView: AnyView {
        AnyView(AsamDetailView(asam: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false, mapName: String? = nil, showTitle: Bool = true) -> AnyView {
        AnyView(AsamSummaryView(asam: self, showMoreDetails: showMoreDetails, showTitle: showTitle))
    }
}
