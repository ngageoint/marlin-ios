//
//  LightDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    
    class LightDefinition: DataSourceDefinition {
        var filterable: Filterable? = LightFilterable()
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFFFFC500)
        var imageName: String?
        var systemImageName: String? = "lightbulb.fill"
        var key: String = "light"
        var metricsKey: String = "lights"
        var name: String = NSLocalizedString("Lights", comment: "Lights data source display name")
        var fullName: String = NSLocalizedString("Lights", comment: "Lights data source full display name")
        var imageScale: CGFloat {
            UserDefaults.standard.imageScale(key) ?? 0.66
        }
        @AppStorage("lightOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DataSources.light)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.light)
        }
        
        static let definition = LightDefinition()
        private init() { }
    }
}
