//
//  NavigationalWarning+DataSourceViewbuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension NavigationalWarning: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(NavigationalWarningDetailView(navigationalWarning: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(NavigationalWarningSummaryView(navigationalWarning: self))
    }
}
