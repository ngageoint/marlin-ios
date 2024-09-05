//
//  AsamDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    class AsamDefinition: DataSourceDefinition {
        var filterable: Filterable? = AsamFilterable()
        var mappable: Bool = true
        var color: UIColor = .black
        var imageName: String? = "asam"
        var systemImageName: String?
        var key: String = "asam"
        var metricsKey: String = "asams"
        var name: String = NSLocalizedString("ASAM", comment: "ASAM data source display name")
        var fullName: String =
        NSLocalizedString("Anti-Shipping Activity Messages", comment: "ASAM data source full display name")
        @AppStorage("asamOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every hour
            return UserDefaults.standard.dataSourceEnabled(DataSources.asam)
            && (Date().timeIntervalSince1970 - (60 * 60)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.asam)
        }

        static let definition = AsamDefinition()
        private init() { }
    }
}
