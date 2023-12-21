//
//  Asam+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData
import Combine

extension Asam: Bookmarkable {
    var canBookmark: Bool {
        return true
    }
    
    var itemKey: String {
        return reference ?? ""
    }
    
    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
        return getAsam(context: context, reference: itemKey)
    }
    
    static func getAsam(context: NSManagedObjectContext, reference: String?) -> Asam? {
        if let reference = reference {
            return context.fetchFirst(Asam.self, key: "reference", value: reference)
        }
        return nil
    }
}

extension Asam: DataSource, Locatable, GeoPackageExportable, GeoJSONExportable {
    static var definition: any DataSourceDefinition = DataSourceDefinitions.asam.definition
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static func postProcess() {
        imageCache.clearCache()
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = 
    NSLocalizedString("ASAM",
                      comment: "ASAM data source display name")
    static var fullDataSourceName: String =
    NSLocalizedString("Anti-Shipping Activity Messages",
                      comment: "ASAM data source full display name")
    static var key: String = DataSourceType.asam.rawValue
    static var metricsKey: String = "asams"
    static var imageName: String? = "asam"
    static var systemImageName: String?
    
    static var color: UIColor = .black
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(Asam.date),
                type: .date),
            ascending: false)
    ]
    static var defaultFilter: [DataSourceFilterParameter] = [
        DataSourceFilterParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(Asam.date),
                type: .date),
            comparison: .window,
            windowUnits: DataSourceWindowUnits.last365Days)
    ]

    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date),
        DataSourceProperty(name: "Location", key: #keyPath(Asam.mgrs10km), type: .location),
        DataSourceProperty(name: "Reference", key: #keyPath(Asam.reference), type: .string),
        DataSourceProperty(name: "Latitude", key: #keyPath(Asam.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Asam.longitude), type: .longitude),
        DataSourceProperty(name: "Navigation Area", key: #keyPath(Asam.navArea), type: .string),
        DataSourceProperty(name: "Subregion", key: #keyPath(Asam.subreg), type: .string),
        DataSourceProperty(name: "Description", key: #keyPath(Asam.asamDescription), type: .string),
        DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string),
        DataSourceProperty(name: "Victim", key: #keyPath(Asam.victim), type: .string)
    ]
    
    static func shouldSync() -> Bool {
        // sync once every hour
        return UserDefaults.standard.dataSourceEnabled(DataSourceDefinitions.asam.definition)
        && (Date().timeIntervalSince1970 - (60 * 60)) >
        UserDefaults.standard.lastSyncTimeSeconds(DataSourceDefinitions.asam.definition)
    }
}

// TODO: This is only for the MSI masterDataList depending on BatchImportable
extension Asam: BatchImportable {
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        return 0
    }
    
    static func dataRequest() -> [MSIRouter] {
        return []
    }
    
    static var seedDataFiles: [String]? {
        return []
    }
    
    static var decodableRoot: Decodable.Type {
        AsamPropertyContainer.self
    }
    
}
