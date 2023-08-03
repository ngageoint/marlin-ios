//
//  RadioBeacon+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension RadioBeacon: DataSourceViewBuilder {
//    typealias Summary = RadioBeaconSummaryView
    var itemTitle: String {
        return "\(self.name ?? "\(self.featureNumber)")"
    }
    
    var detailView: AnyView {
        AnyView(RadioBeaconDetailView(radioBeacon: self))
    }
    
//    func summaryView() -> Summary {
//        RadioBeaconSummaryView(radioBeacon: self)
//    }
    
    var summary: some DataSourceSummaryView {
        RadioBeaconSummaryView(radioBeacon: self)
    }
}
