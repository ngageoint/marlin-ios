//
//  Bookmark+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import Foundation
import CoreData
import UIKit
import SwiftUI

protocol Bookmarkable {
    var key: String { get }
    var itemKey: String? { get }
    var bookmark: Bookmark? { get }
    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable?
}

extension Bookmarkable {
    var bookmark: Bookmark? {
        return try? PersistenceController.current.viewContext.fetchFirst(Bookmark.self, predicate: NSPredicate(format: "id == %@ AND dataSource == %@", itemKey ?? "", key))
    }
    
    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
        return nil
    }
}

class Bookmark: NSManagedObject, BatchImportable {
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        return 0
    }
    
    static func dataRequest() -> [MSIRouter] {
        return []
    }
    
    static var seedDataFiles: [String]?
    
    static var decodableRoot: Decodable.Type = AsamPropertyContainer.self
    
    static func shouldSync() -> Bool {
        return false
    }
    
    static func postProcess() {
        
    }
    
    func getDataSourceItem(context: NSManagedObjectContext) -> (any Bookmarkable)? {
        print("data source is \(dataSource)")
        switch(dataSource) {
        case Asam.key:
            return Asam.getItem(context: context, itemKey: self.id)
        case Modu.key:
            return Modu.getItem(context: context, itemKey: self.id)
        case Port.key:
            return Port.getItem(context: context, itemKey: self.id)
        case NavigationalWarning.key:
            return NavigationalWarning.getItem(context: context, itemKey: self.id)
        case NoticeToMariners.key:
            return NoticeToMariners.getItem(context: context, itemKey: self.id)
        case DifferentialGPSStation.key:
            return DifferentialGPSStation.getItem(context: context, itemKey: self.id)
        case Light.key:
            return Light.getItem(context: context, itemKey: self.id)
        case RadioBeacon.key:
            return RadioBeacon.getItem(context: context, itemKey: self.id)
        case ElectronicPublication.key:
            return ElectronicPublication.getItem(context: context, itemKey: self.id)
        case GeoPackageFeatureItem.key:
            return GeoPackageFeatureItem.getItem(context: context, itemKey: self.id)
        default:
            print("default")
        }
        return nil
    }
}

extension Bookmark: DataSource {
    static var metricsKey: String = "bookmark"
    
    static var key: String = "bookmark"
    
    var color: UIColor {
        Self.color
    }

    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Date", key: #keyPath(Bookmark.timestamp), type: .date)
    ]
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Timestamp", key: #keyPath(Bookmark.timestamp), type: .date), ascending: false)]
    
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var isMappable: Bool = false
    static var dataSourceName: String = "Bookmarks"
    static var fullDataSourceName: String = "Bookmarks"
    static var color: UIColor = UIColor(argbValue: 0xFFFF9500)
    static var imageName: String? = nil
    static var systemImageName: String? = "bookmark.fill"
    static var imageScale: CGFloat = 1.0
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}

extension Bookmark: DataSourceViewBuilder {    
    var itemTitle: String {
        return "Bookmark \(self.id ?? "")"
    }
    var detailView: AnyView {
        if let viewBuilder = getDataSourceItem(context: PersistenceController.current.viewContext) as? (any DataSourceViewBuilder) {
            return viewBuilder.detailView
        }
        return AnyView(Text("Bookmark detail \(self.dataSource ?? "") \(self.id ?? "")"))
    }
    
    var summary: some DataSourceSummaryView {
        BookmarkSummary(bookmark: self)
    }
}
