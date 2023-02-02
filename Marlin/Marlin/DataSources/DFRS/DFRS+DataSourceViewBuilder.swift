//
//  DFRS+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension DFRS: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.stationName ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(DFRSDetailView(dfrs: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(DFRSSummaryView(dfrs: self, showMoreDetails: showMoreDetails, showSectionHeader: showSectionHeader))
    }
}
