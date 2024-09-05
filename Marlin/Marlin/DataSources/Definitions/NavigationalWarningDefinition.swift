//
//  NavigationalWarningDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {

    class NavigationalWarningDefinition: DataSourceDefinition {
        var filterable: Filterable? = NavigationalWarningFilterable()
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFFD32F2F)
        var imageName: String?
        var systemImageName: String? = "exclamationmark.triangle.fill"
        var key: String = "navWarning"
        var metricsKey: String = "navigational_warnings"
        var name: String = NSLocalizedString("Warnings", comment: "Warnings data source display name")
        var fullName: String =
        NSLocalizedString("Navigational Warnings", comment: "Warnings data source full display name")
        @AppStorage("navWarningOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every hour
            return UserDefaults.standard.dataSourceEnabled(NavigationalWarning.definition)
            && (Date().timeIntervalSince1970 - (60 * 60)) >
            UserDefaults.standard.lastSyncTimeSeconds(NavigationalWarning.definition)
        }

        static let definition = NavigationalWarningDefinition()
        private init() { }
    }
}
