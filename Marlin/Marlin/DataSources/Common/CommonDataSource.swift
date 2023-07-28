//
//  CommonDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 7/10/23.
//

import Foundation
import UIKit
import MapKit

class CommonDataSource: NSObject, DataSource {
    var itemKey: String? {
        return nil
    }
    static var metricsKey: String = "Common"
    
    static var key: String = "Common"
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(CommonDataSource.location), type: .location)
    ]
    
    static var defaultSort: [DataSourceSortParameter] = []
    
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var isMappable: Bool = false
    
    static var dataSourceName: String = "Common"
    
    static var fullDataSourceName: String = "Common"
    
    static var color: UIColor = .clear
    
    static var imageName: String?
    
    static var systemImageName: String?
    
    var color: UIColor = .clear
    
    static var imageScale: CGFloat = 0.0
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    @objc var location: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
}
