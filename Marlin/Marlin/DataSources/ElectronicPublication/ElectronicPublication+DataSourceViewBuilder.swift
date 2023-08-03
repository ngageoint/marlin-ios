//
//  ElectronicPublication+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import Foundation
import SwiftUI

extension ElectronicPublication: DataSourceViewBuilder {
//    typealias Summary = ElectronicPublicationSummaryView
    var itemTitle: String {
        return "\(self.sectionDisplayName ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(ElectronicPublicationDetailView(electronicPublication: self))
    }
    
//    func summaryView() -> Summary {
//        ElectronicPublicationSummaryView(electronicPublication: self)
//    }
    
    var summary: some DataSourceSummaryView {
        ElectronicPublicationSummaryView(electronicPublication: self)
    }
}
