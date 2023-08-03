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
    
    var summary: some DataSourceSummaryView {
        PortSummaryView(port: self)
    }
}
