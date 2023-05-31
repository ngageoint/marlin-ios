//
//  Port+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Port: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.portName ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(PortDetailView(port: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false, mapName: String? = nil, showTitle: Bool = true) -> AnyView {
        AnyView(PortSummaryView(port: self, showMoreDetails: showMoreDetails, showTitle: showTitle))
    }
}
