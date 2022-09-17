//
//  Asam+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Asam: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(AsamDetailView(asam: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(AsamSummaryView(asam: self, showMoreDetails: showMoreDetails))
    }
}
