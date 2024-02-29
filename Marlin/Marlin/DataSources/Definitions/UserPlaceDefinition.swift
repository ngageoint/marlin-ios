//
//  UserPlaceDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    
    class UserPlaceDefinition: DataSourceDefinition {
        var filterable: Filterable? = CommonFilterable()
        var mappable: Bool = false
        var color: UIColor = Color.primaryUIColor
        var imageName: String?
        var systemImageName: String? = "mappin"
        var key: String = "UserPlace"
        var metricsKey: String = "UserPlace"
        var name: String = "My Places"
        var fullName: String = "My Places"
        @AppStorage("userPlaceOrder") var order: Int = 0
        
        static let definition = UserPlaceDefinition()
        private init() { }
    }
}
