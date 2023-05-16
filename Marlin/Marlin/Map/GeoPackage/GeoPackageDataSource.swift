//
//  GeoPackageDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 4/10/23.
//

import Foundation
import SwiftUI
import geopackage_ios

class GeoPackageFeatureItem: NSObject, DataSourceLocation, DataSourceViewBuilder {
    var coordinate: CLLocationCoordinate2D
    
    var latitude: Double { coordinate.latitude }
    
    var longitude: Double { coordinate.longitude }
    
    static var cacheTiles: Bool = false
    
    var itemTitle: String {
        let title = "GeoPackage Feature"
        if self.maxFeaturesReached {
            return "\(self.featureCount) Features"
        }
        if let values = self.featureRowData?.values(), let titleKey = values.keys.first(where: { key in
            return ["name", "title", "primaryfield"].contains((key as? String)?.lowercased())
        }) {
            return values[titleKey] as? String ?? title
        }
        return title
    }
    
    var secondaryTitle: String? {
        if let values = self.featureRowData?.values(), let titleKey = values.keys.first(where: { key in
            return ["secondaryfield", "subtitle", "variantfield"].contains((key as? String)?.lowercased());
        }) {
            return values[titleKey] as? String
        }
        return nil
    }
    
    var dateString: String? {
        if let values = self.featureRowData?.values(), let titleKey = values.keys.first(where: { key in
            return ["date", "timestamp"].contains((key as? String)?.lowercased())
        }) {
            if let date = values[titleKey] as? Date {
                return GeoPackageFeatureItem.dateFormatter.string(from: date)
            }
        }
        return nil
    }
    
    var detailView: AnyView {
        AnyView(GeoPackageFeatureItemDetailView(featureItem: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false, mapName: String? = nil) -> AnyView {
        AnyView(GeoPackageFeatureItemSummaryView(featureItem: self))
    }
    
    static var properties: [DataSourceProperty] = []
    
    static var defaultSort: [DataSourceSortParameter] = []
    
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var isMappable: Bool = true
    
    static var dataSourceName: String = "GeoPackage Feature"
    
    static var fullDataSourceName: String = "GeoPackage Feature"
    
    static var color: UIColor = .brown
    
    static var imageName: String?
    
    static var systemImageName: String?
    
    static var key: String = "gpfeature"
    static var metricsKey: String = "geopackage"
    
    var color: UIColor = .brown
    
    static var imageScale: CGFloat = 1.0

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    var featureId: Int
    var featureDetail: String?
    var icon: UIImage?
    var mediaRows: [GPKGMediaRow]?
    var attributeRows: [GeoPackageFeatureItem]?
    var featureRowData: GPKGFeatureRowData?
    var featureDataTypes: [String : String]?
    var layerName: String?
    var style: GPKGStyleRow?
    var maxFeaturesReached: Bool
    var featureCount: Int
    
    init(maxFeaturesReached: Bool = false, featureCount: Int = 0, layerName: String? = nil) {
        self.maxFeaturesReached = maxFeaturesReached
        self.featureCount = featureCount
        self.layerName = layerName
        self.featureId = 0
        self.coordinate = kCLLocationCoordinate2DInvalid
    }
    
    convenience init(layerName: String? = nil, featureId: Int = 0, featureRowData: GPKGFeatureRowData?, featureDataTypes: [String : String]? = nil, coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid, icon: UIImage? = nil, style: GPKGStyleRow? = nil, mediaRows: [GPKGMediaRow]? = nil, attributeRows: [GeoPackageFeatureItem]? = nil) {
        self.init(maxFeaturesReached: false, featureCount: 1, layerName: layerName)
        self.featureId = featureId
        self.featureRowData = featureRowData
        self.featureDataTypes = featureDataTypes
        self.coordinate = coordinate
        self.icon = icon
        self.style = style
        self.mediaRows = mediaRows
        self.attributeRows = attributeRows
    }
    
    func valueString(key: String, value: Any) -> String {
        if let dataType = self.featureDataTypes?[key] {
            let gpkgDataType = GPKGDataTypes.fromName(dataType)
            if (gpkgDataType == GPKG_DT_BOOLEAN) {
                return "\((value as? Int) == 0 ? "true" : "false")"
            } else if (gpkgDataType == GPKG_DT_DATE) {
                let dateDisplayFormatter = DateFormatter();
                dateDisplayFormatter.dateFormat = "yyyy-MM-dd";
                dateDisplayFormatter.timeZone = TimeZone(secondsFromGMT: 0);
                
                if let date = value as? Date {
                    return "\(dateDisplayFormatter.string(from: date))"
                }
            } else if (gpkgDataType == GPKG_DT_DATETIME) {
                let dateDisplayFormatter = DateFormatter();
                dateDisplayFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss";
                dateDisplayFormatter.timeZone = TimeZone(secondsFromGMT: 0);
                if let date = value as? Date {
                    return "\(dateDisplayFormatter.string(from: date))"
                }
            } else {
                return "\(value)"
            }
        } else {
            return "\(value)"
        }
        return ""
    }
    
}
