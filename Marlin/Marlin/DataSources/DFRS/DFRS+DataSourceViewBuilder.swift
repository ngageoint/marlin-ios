//
//  DFRS+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension DFRS: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(DFRSDetailView(dfrs: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(DFRSSummaryView(dfrs: self, showMoreDetails: showMoreDetails, showSectionHeader: showSectionHeader))
    }
}
