//
//  DataSourceFilterParameterDisplayBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

class DataSourceFilterParameterDisplayBuilder {

    var property: DataSourceProperty
    var comparison: DataSourceFilterComparison

    init(property: DataSourceProperty, comparison: DataSourceFilterComparison) {
        self.property = property
        self.comparison = comparison
    }

    func display() {
        
    }
}
