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
        AnyView(ElectronicPublicationSummaryView(electronicPublication: self)
            .setBookmark(bookmark))
    }
    
    var summary: some DataSourceSummaryView {
        ElectronicPublicationSummaryView(electronicPublication: self)
    }
}
