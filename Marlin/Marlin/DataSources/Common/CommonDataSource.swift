//
//  CommonDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 7/10/23.
//

import Foundation
import UIKit
import MapKit
import SwiftUI

struct CommonSummaryView: DataSourceSummaryView {
    var showSectionHeader: Bool = false
    
    var bookmark: Bookmark?
    
    var common: CommonDataSource
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    var showBookmarkNotes: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(common.name ?? "")
                .overline()
        }
    }
}

class CommonDataSource: NSObject, DataSource, DataSourceViewBuilder, ObservableObject, GeoJSONExportable {
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: location.longitude, andYValue: location.latitude)
    }
    
    var itemTitle: String {
        return "\(self.name ?? "")"
    }
    var detailView: AnyView {
        AnyView(Text(name ?? ""))
    }
    
    var summary: some DataSourceSummaryView {
        CommonSummaryView(common: self)
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
    
    static var color: UIColor = Color.primaryUIColor
    
    static var imageName: String?
    
    static var systemImageName: String? = "mappin"
    
    var color: UIColor = Color.primaryUIColor
    
    static var imageScale: CGFloat = 0.0
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    @Published @objc var location: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    @Published var name: String?
        
    init(name: String? = nil, location: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid){
        self.name = name
        self.location = location
    }
}
