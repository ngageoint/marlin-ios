//
//  PortDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    
    class PortDefinition: DataSourceDefinition {
        var filterable: Filterable? = PortFilterable()
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFF5856d6)
        var imageName: String? = "port"
        var systemImageName: String?
        var key: String = "port"
        var metricsKey: String = "ports"
        var name: String = NSLocalizedString("Ports", comment: "Port data source display name")
        var fullName: String = NSLocalizedString("World Ports", comment: "Port data source full display name")
        @AppStorage("portOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DataSources.port)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.port)
        }
        
        var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return dateFormatter
        }
        
        static let definition = PortDefinition()
        private init() { }
    }
}
