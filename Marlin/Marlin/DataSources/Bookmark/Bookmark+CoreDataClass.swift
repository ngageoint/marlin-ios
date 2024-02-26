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
    static var definition: any DataSourceDefinition { get }
    var canBookmark: Bool { get }
    var itemKey: String { get }
}

extension Bookmarkable {

    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
        return nil
    }
    
    var key: String {
        Self.definition.key
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

}

extension Bookmark: DataSource {
    var itemKey: String {
        self.id ?? ""
    }
    var itemTitle: String {
        return "Bookmark \(self.id ?? "")"
    }
    static var definition: any DataSourceDefinition = DataSourceDefinitions.bookmark.definition
    static var metricsKey: String = "bookmark"
    
    static var key: String = "bookmark"
    
    var color: UIColor {
        Self.color
    }

    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Date", key: #keyPath(Bookmark.timestamp), type: .date)
    ]
    
    static var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Timestamp",
                key: #keyPath(Bookmark.timestamp),
                type: .date
            ),
            ascending: false)
    ]

    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var isMappable: Bool = false
    static var dataSourceName: String = "Bookmarks"
    static var fullDataSourceName: String = "Bookmarks"
    static var color: UIColor = UIColor(argbValue: 0xFFFF9500)
    static var imageName: String?
    static var systemImageName: String? = "bookmark.fill"
    static var imageScale: CGFloat = 1.0
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}
