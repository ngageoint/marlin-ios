//
//  ModuDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    class ModuDefinition: DataSourceDefinition {
        var filterable: Filterable? = ModuFilterable()
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFF0042A4)
        var imageName: String? = "modu"
        var systemImageName: String?
        let key: String = "modu"
        var metricsKey: String = "modus"
        var name: String = NSLocalizedString("MODU", comment: "MODU data source display name")
        var fullName: String =
        NSLocalizedString("Mobile Offshore Drilling Units", comment: "MODU data source full display name")
        @AppStorage("moduOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every hour
            return UserDefaults.standard.dataSourceEnabled(DataSources.modu)
            && (Date().timeIntervalSince1970 - (60 * 60)) > UserDefaults.standard.lastSyncTimeSeconds(DataSources.modu)
        }
        
        static let definition = ModuDefinition()
        private init() { }
    }
}
