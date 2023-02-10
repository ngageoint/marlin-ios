//
//  DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import Foundation
import UIKit
import SwiftUI
import MapKit
import CoreData
import Alamofire

struct Throwable<T: Decodable>: Decodable {
    let result: Result<T, Error>
    
    init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}

protocol BatchImportable: NSManagedObject, Identifiable {
    @discardableResult
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int
    static func dataRequest() -> [MSIRouter]
    static var key: String { get }
    static var seedDataFiles: [String]? { get }
    static var decodableRoot: Decodable.Type { get }
    static func shouldSync() -> Bool
    static func getRequeryRequest(initialRequest: URLRequestConvertible) -> URLRequestConvertible?
    static func postProcess()
}

extension BatchImportable {
    static func getRequeryRequest(initialRequest: URLRequestConvertible) -> URLRequestConvertible? {
        return nil
    }
}

class DataSourceImageCache {
    static let shared = DataSourceImageCache()
    var images: [String : UIImage] = [:]
    
    func getCachedImage(dataSourceKey: String, zoomLevel: Int) -> UIImage? {
        return images["\(dataSourceKey)\(zoomLevel)"]
    }
    
    func addCachedImage(dataSourceKey: String, zoomLevel: Int, image: UIImage) {
        images["\(dataSourceKey)\(zoomLevel)"] = image
    }
}

enum DataSourcePropertyType: Codable {
    case string
    case date
    case int
    case float
    case double
    case boolean
    case enumeration
    case location
    case latitude
    case longitude
    
    func defaultComparison() -> DataSourceFilterComparison {
        switch (self) {
            
        case .string, .enumeration, .int, .double, .float, .boolean, .latitude, .longitude:
            return .equals
        case .date:
            return .window
        case .location:
            return .nearMe
        }
    }
    
    func comparisons() -> [DataSourceFilterComparison] {
        switch (self) {
        case .date:
            return DataSourceFilterComparison.dateSubset()
        case .enumeration:
            return DataSourceFilterComparison.enumerationSubset()
        case .location:
            return DataSourceFilterComparison.locationSubset()
        case .double, .float, .int, .latitude, .longitude:
            return DataSourceFilterComparison.numberSubset()
        case .string:
            return DataSourceFilterComparison.stringSubset()
        case .boolean:
            return DataSourceFilterComparison.booleanSubset()
        }
    }
}

struct DataSourceProperty: Hashable, Identifiable, Codable {
    var id: String { "\(name)\(key)" }
    let name: String
    let key: String
    let type: DataSourcePropertyType
    let enumerationValues: [String: [String]]?
    let requiredInFilter: Bool
    let subEntityKey: String?
    
    init(name: String, key: String, type: DataSourcePropertyType, subEntityKey: String? = nil, enumerationValues: [String: [String]]? = nil, requiredInFilter: Bool = false) {
        self.name = name
        self.key = key
        self.type = type
        self.subEntityKey = subEntityKey
        self.enumerationValues = enumerationValues
        self.requiredInFilter = requiredInFilter
    }
}

protocol DataSource {
    static var properties: [DataSourceProperty] { get }
    static var defaultSort: [DataSourceSortParameter] { get }
    static var defaultFilter: [DataSourceFilterParameter] { get }
    static var isMappable: Bool { get }
    static var dataSourceName: String { get }
    static var fullDataSourceName: String { get }
    static var key: String { get }
    var key: String { get }
    static var color: UIColor { get }
    static var imageName: String? { get }
    static var systemImageName: String? { get }
    var color: UIColor { get }
    static var image: UIImage? { get }
    static var imageScale: CGFloat { get }
    var coordinate: CLLocationCoordinate2D? { get }
    func view(on: MKMapView) -> MKAnnotationView?
    static func cachedImage(zoomLevel: Int) -> UIImage?
    static func cacheImage(zoomLevel: Int, image: UIImage)
    static var dateFormatter: DateFormatter { get }
}

extension DataSource {
    
    static func cachedImage(zoomLevel: Int) -> UIImage? {
        return DataSourceImageCache.shared.getCachedImage(dataSourceKey: key, zoomLevel: zoomLevel)
    }
    
    static func cacheImage(zoomLevel: Int, image: UIImage) {
        DataSourceImageCache.shared.addCachedImage(dataSourceKey: key, zoomLevel: zoomLevel, image: image)
    }
    
    static var image: UIImage? {
        if let imageName = imageName {
            return UIImage(named: imageName)
        } else if let systemImageName = systemImageName {
            return UIImage(systemName: systemImageName)
        }
        return nil
    }
    
    func view(on: MKMapView) -> MKAnnotationView? {
        return nil
    }
    
    var coordinate: CLLocationCoordinate2D? {
        return nil
    }
    
    var key: String {
        return Self.key
    }
}

protocol DataSourceViewBuilder: DataSource {
    var detailView: AnyView { get }
    func summaryView(showMoreDetails: Bool, showSectionHeader: Bool) -> AnyView
    var itemTitle: String { get }
}

