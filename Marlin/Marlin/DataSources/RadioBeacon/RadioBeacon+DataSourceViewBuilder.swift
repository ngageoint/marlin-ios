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
        if let volumeNumber = volumeNumber {
            return AnyView(RadioBeaconDetailView(featureNumber: Int(featureNumber), volumeNumber: volumeNumber))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var summary: some DataSourceSummaryView {
        RadioBeaconSummaryView(radioBeacon: RadioBeaconModel(radioBeacon: self))
    }
}

extension RadioBeaconModel: DataSourceViewBuilder {
    var detailView: AnyView {
        if let volumeNumber = volumeNumber, let featureNumber = featureNumber {
            return AnyView(RadioBeaconDetailView(featureNumber: Int(featureNumber), volumeNumber: volumeNumber))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var summary: some DataSourceSummaryView {
        RadioBeaconSummaryView(radioBeacon: self)
    }
}
