//
//  Modu+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Modu: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.name ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(ModuDetailView(modu: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(ModuSummaryView(modu: self, showMoreDetails: showMoreDetails))
    }
}
