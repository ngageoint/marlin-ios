//
//  RouteDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    class RouteDefinition: DataSourceDefinition {
        var filterable: Filterable? = RouteFilterable()
        var mappable: Bool = true
        var color: UIColor = .black
        var imageName: String?
        var systemImageName: String? = "arrow.triangle.turn.up.right.diamond.fill"
        var key: String = "route"
        var metricsKey: String = "routes"
        var name: String = NSLocalizedString("Routes", comment: "Route data source display name")
        var fullName: String = NSLocalizedString("Routes", comment: "Route data source full display name")
        @AppStorage("routeOrder") var order: Int = 0
        
        static let definition = RouteDefinition()
        private init() { }
    }
}
