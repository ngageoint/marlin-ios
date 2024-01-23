//
//  Modu+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension Modu: Bookmarkable {
    var canBookmark: Bool {
        return true
    }
    
    var itemKey: String {
        return name ?? ""
    }
    
    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
        return getModu(context: context, name: itemKey)
    }
    
    static func getModu(context: NSManagedObjectContext, name: String?) -> Modu? {
        if let name = name {
            return context.fetchFirst(Modu.self, key: "name", value: name)
        }
        return nil
    }
}

extension Modu: Locatable, GeoPackageExportable, GeoJSONExportable {
    var itemTitle: String {
        return "\(self.name ?? "")"
    }
    
    static var definition: any DataSourceDefinition = DataSourceDefinitions.modu.definition
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("MODU", comment: "MODU data source display name")
    static var fullDataSourceName: String = 
    NSLocalizedString("Mobile Offshore Drilling Units", comment: "MODU data source display name")
    static var key: String = "modu"
    static var metricsKey: String = "modus"
    static var imageName: String? = "modu"
    static var systemImageName: String?
    static var color: UIColor = UIColor(argbValue: 0xFF0042A4)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(Modu.date),
                type: .date
            ),
            ascending: false
        )
    ]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Modu.mgrs10km), type: .location),
        DataSourceProperty(name: "Subregion", key: #keyPath(Modu.subregion), type: .int),
        DataSourceProperty(name: "Region", key: #keyPath(Modu.region), type: .int),
        DataSourceProperty(name: "Longitude", key: #keyPath(Modu.longitude), type: .longitude),
        DataSourceProperty(name: "Latitude", key: #keyPath(Modu.latitude), type: .latitude),
        DataSourceProperty(name: "Distance", key: #keyPath(Modu.distance), type: .double),
        DataSourceProperty(name: "Special Status", key: #keyPath(Modu.specialStatus), type: .string),
        DataSourceProperty(name: "Rig Status", key: #keyPath(Modu.rigStatus), type: .string),
        DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Modu.name), type: .string),
        DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date)
    ]
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }

    static func postProcess() {
        imageCache.clearCache()
    }

    static func shouldSync() -> Bool {
        // sync once every hour
        return UserDefaults.standard.dataSourceEnabled(Modu.definition)
        && (Date().timeIntervalSince1970 - (60 * 60)) > UserDefaults.standard.lastSyncTimeSeconds(Modu.definition)
    }
}

// TODO: This is only for the MSI masterDataList depending on BatchImportable
extension Modu: BatchImportable {

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
        ModuPropertyContainer.self
    }

}
