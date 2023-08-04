//
//  DFRS+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension DFRS: DataSourceViewBuilder {
    var summary: some DataSourceSummaryView {
        DFRSSummaryView(dfrs: self)
    }
        
    var itemTitle: String {
        return "\(self.stationName ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(DFRSDetailView(dfrs: self))
    }
}
