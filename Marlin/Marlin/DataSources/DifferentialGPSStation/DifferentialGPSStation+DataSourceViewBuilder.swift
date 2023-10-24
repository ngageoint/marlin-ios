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
        return "\(self.name ?? "\(self.featureNumber)")"
    }
    
    var detailView: AnyView {
        if let volumeNumber = volumeNumber {
            return AnyView(DifferentialGPSStationDetailView(featureNumber: Int(featureNumber), volumeNumber: volumeNumber))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var summary: some DataSourceSummaryView {
        DifferentialGPSStationSummaryView(differentialGPSStation: DifferentialGPSStationModel(differentialGPSStation: self))
    }
}

extension DifferentialGPSStationModel: DataSourceViewBuilder {
    var detailView: AnyView {
        if let volumeNumber = volumeNumber, let featureNumber = featureNumber {
            return AnyView(DifferentialGPSStationDetailView(featureNumber: Int(featureNumber), volumeNumber: volumeNumber))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var summary: some DataSourceSummaryView {
        DifferentialGPSStationSummaryView(differentialGPSStation: self)
    }
}
