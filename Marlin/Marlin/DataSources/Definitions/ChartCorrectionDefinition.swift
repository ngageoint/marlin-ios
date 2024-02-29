//
//  ChartCorrectionDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    
    class ChartCorrectionDefinition: DataSourceDefinition {
        var filterable: Filterable? = ChartCorrectionFilterable()
        var mappable: Bool = false
        var color: UIColor = UIColor.red
        var imageName: String?
        var systemImageName: String? = "antenna.radiowaves.left.and.right"
        var key: String = "chartCorrection"
        var metricsKey: String = "corrections"
        var name: String = NSLocalizedString("Chart Corrections", comment: "Chart Corrections data source display name")
        var fullName: String =
        NSLocalizedString("Chart Corrections", comment: "Chart Corrections data source full display name")
        @AppStorage("chartCorrectionOrder") var order: Int = 0
        
        static let definition = ChartCorrectionDefinition()
        private init() { }
    }
}
