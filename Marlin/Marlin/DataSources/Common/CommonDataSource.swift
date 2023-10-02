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
import GeoJSON

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

class CommonDataSource: NSObject, Locatable, DataSourceViewBuilder, ObservableObject, GeoJSONExportable, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? values.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name, forKey: .name)
    }
    
    var itemKey: String {
        return "\(itemTitle)--\(coordinate.latitude)--\(coordinate.longitude)"
    }
    
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
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
        DataSourceProperty(name: "Location", key: #keyPath(CommonDataSource.coordinate), type: .location)
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
    
    @Published @objc var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    @Published var name: String?
        
    init(name: String? = nil, location: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid){
        self.name = name
        self.coordinate = location
    }
    
    convenience init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)
            if let ds = try? decoder.decode(CommonDataSource.self, from: jsonData) {
                self.init(name: ds.name, location: ds.coordinate)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
