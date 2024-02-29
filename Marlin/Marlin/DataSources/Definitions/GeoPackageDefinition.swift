//
//  GeoPackageDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {

    class GeoPackageDefinition: DataSourceDefinition {
        var filterable: Filterable?
        var mappable: Bool = true
        var color: UIColor = UIColor.brown
        var imageName: String?
        var systemImageName: String?
        var key: String = "gpfeature"
        var metricsKey: String = "geopackage"
        var name: String =
        NSLocalizedString("GeoPackage Feature", comment: "GeoPackage Feature data source display name")
        var fullName: String =
        NSLocalizedString("GeoPackage Feature", comment: "GeoPackage Feature data source full display name")
        @AppStorage("gpfeatureOrder") var order: Int = 0

        static let definition = GeoPackageDefinition()
        private init() { }
    }
}
