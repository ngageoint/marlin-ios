//
//  DifferentialGPSStation+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension DifferentialGPSStation: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.featureNumber) \(self.volumeNumber ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(DifferentialGPSStationDetailView(differentialGPSStation: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(DifferentialGPSStationSummaryView(differentialGPSStation: self, showMoreDetails: showMoreDetails, showSectionHeader: showSectionHeader))
    }
}
