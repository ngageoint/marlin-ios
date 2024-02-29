//
//  DifferentialGPSStationDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    class DifferentialGPSStationDefinition: DataSourceDefinition {
        var filterable: Filterable? = DifferentialGPSStationFilterable()
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFF00E676)
        var imageName: String? = "dgps"
        var systemImageName: String?
        var key: String = "differentialGPSStation"
        var metricsKey: String = "dgpsStations"
        var name: String = NSLocalizedString("DGPS", comment: "Differential GPS Station data source display name")
        var fullName: String =
        NSLocalizedString("Differential GPS Stations",
                          comment: "Differential GPS Station data source full display name")
        var imageScale: CGFloat {
            UserDefaults.standard.imageScale(key) ?? 0.66
        }
        @AppStorage("differentialGPSStationOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DataSources.dgps)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.dgps)
        }
        
        static let definition = DifferentialGPSStationDefinition()
        private init() { }
    }
}
