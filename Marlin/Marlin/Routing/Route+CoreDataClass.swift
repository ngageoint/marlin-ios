//
//  Route+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/14/23.
//

import Foundation
import CoreData
import UIKit

class Route: NSManagedObject {
    
}

extension Route: DataSource {
    static var key: String = "route"
    static var metricsKey: String = "routes"
    
    static var properties: [DataSourceProperty] = []
    
    static var defaultSort: [DataSourceSortParameter] = []
    
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var isMappable: Bool = true
    
    static var dataSourceName: String = NSLocalizedString("Routes", comment: "Route data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Routes", comment: "Route data source full display name")
    
    static var color: UIColor = .black
    var color: UIColor {
        Self.color
    }
    
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var imageName: String? = nil
    
    static var systemImageName: String? = "arrow.triangle.turn.up.right.diamond.fill"
        
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    var itemKey: String {
        return "\(name ?? "")"
    }
    
    var itemTitle: String {
        return "\(name ?? "")"
    }
}
