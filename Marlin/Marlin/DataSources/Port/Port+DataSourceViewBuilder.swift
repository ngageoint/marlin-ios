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
        return AnyView(PortDetailView(portNumber: portNumber))
    }
    
    var summary: some DataSourceSummaryView {
        PortSummaryView(port: PortModel(port: self))
    }
}

extension PortModel: DataSourceViewBuilder {
    var detailView: AnyView {
        return AnyView(PortDetailView(portNumber: Int64(portNumber)))
    }
    
    var summary: some DataSourceSummaryView {
        PortSummaryView(port: self)
    }
}
