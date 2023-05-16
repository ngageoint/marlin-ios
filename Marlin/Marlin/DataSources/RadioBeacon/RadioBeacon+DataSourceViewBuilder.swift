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
        return "\(self.featureNumber) \(self.volumeNumber ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(RadioBeaconDetailView(radioBeacon: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false, mapName: String? = nil) -> AnyView {
        AnyView(RadioBeaconSummaryView(radioBeacon: self, showMoreDetails: showMoreDetails, showSectionHeader: showSectionHeader))
    }
}
