//
//  Port+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Port: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(PortDetailView(port: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(PortSummaryView(port: self, showMoreDetails: showMoreDetails))
    }
}
