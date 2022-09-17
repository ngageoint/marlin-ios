//
//  Light+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Light: DataSourceViewBuilder {
    var detailView: AnyView {
        if let featureNumber = self.featureNumber, let volumeNumber = self.volumeNumber {
            return AnyView(LightDetailView(featureNumber: featureNumber, volumeNumber: volumeNumber).navigationTitle("\(name ?? Light.dataSourceName)" ))
        }
        return AnyView(EmptyView())
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(LightSummaryView(light: self, showMoreDetails: showMoreDetails))
    }
}