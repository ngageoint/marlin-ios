//
//  RadioBeaconDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    
    class RadioBeaconDefinition: DataSourceDefinition {
        var filterable: Filterable? = RadioBeaconFilterable()
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFF007BFF)
        var imageName: String? = "settings_input_antenna"
        var systemImageName: String?
        var key: String = "radioBeacon"
        var metricsKey: String = "radioBeacons"
        var name: String = NSLocalizedString("Beacons", comment: "Radio Beacons data source display name")
        var fullName: String =
        NSLocalizedString("Radio Beacons", comment: "Radio Beacons data source full display name")
        var imageScale: CGFloat {
            UserDefaults.standard.imageScale(key) ?? 0.66
        }
        @AppStorage("radioBeaconOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DataSources.radioBeacon)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.radioBeacon)
        }
        
        static let definition = RadioBeaconDefinition()
        private init() { }
    }
}
