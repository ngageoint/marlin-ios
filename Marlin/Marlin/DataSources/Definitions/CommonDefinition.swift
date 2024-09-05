//
//  CommonDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    class CommonDefinition: DataSourceDefinition {
        var filterable: Filterable? = CommonFilterable()
        var mappable: Bool = false
        var color: UIColor = Color.primaryUIColor
        var imageName: String?
        var systemImageName: String? = "mappin"
        var key: String = "Common"
        var metricsKey: String = "Common"
        var name: String = "Common"
        var fullName: String = "Common"
        @AppStorage("CommonOrder") var order: Int = 0

        static let definition = CommonDefinition()
        private init() { }
    }
}
