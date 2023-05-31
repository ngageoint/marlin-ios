//
//  RadioBeacon+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension RadioBeacon: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.name ?? "\(self.featureNumber)")"
    }
    
    var detailView: AnyView {
        AnyView(RadioBeaconDetailView(radioBeacon: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false, mapName: String? = nil, showTitle: Bool = true) -> AnyView {
        AnyView(RadioBeaconSummaryView(radioBeacon: self, showMoreDetails: showMoreDetails, showSectionHeader: showSectionHeader))
    }
}
