//
//  SearchProviderDataDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 3/11/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    class SearchProviderDataDefinition: DataSourceDefinition {
        var filterable: Filterable?
        var mappable: Bool = true
        var color: UIColor = .systemIndigo
        var imageName: String?
        var systemImageName: String? = "magnifyingglass"
        var key: String = "search"
        var metricsKey: String = "search"
        var name: String = NSLocalizedString("Search", comment: "Search provider data source display name")
        var fullName: String =
        NSLocalizedString("Search Provider Data", comment: "Search provider data full display name")
        var order: Int = 0
        func shouldSync() -> Bool {
            return false
        }

        static let definition = SearchProviderDataDefinition()
        private init() { }
    }
}
