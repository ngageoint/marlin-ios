//
//  ElectronicPublication+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import Foundation
import SwiftUI

extension ElectronicPublication: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.sectionDisplayName ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(ElectronicPublicationDetailView(electronicPublication: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(ElectronicPublicationSummaryView(electronicPublication: self, showMoreDetails: showMoreDetails))
    }
}
