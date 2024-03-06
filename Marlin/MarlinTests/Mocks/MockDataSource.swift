//
//  MockDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation
import CoreLocation

@testable import Marlin

enum MockEnum: String, CaseIterable, CustomStringConvertible {
    case Y
    case N
    
    static func fromValue(_ value: String?) -> MockEnum {
        guard let value = value else {
            return .Y
        }
        return MockEnum(rawValue: value) ?? .Y
    }
    
    var description: String {
        switch self {
        case .Y:
            return "Yes"
        case .N:
            return "No"
        }
    }
    
    static var keyValueMap: [String: [String]] {
        DecisionEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append($1.rawValue)
            return $0[$1.description] = array
        }
    }
}

extension DataSources {
    static let mockDataSource: MockDataSourceDefinition = MockDataSourceDefinition()
    static let mockDataSourceDefaultSort: MockDataSourceDefaultSortDefinition = MockDataSourceDefaultSortDefinition()
    static let mockDataSourceNonMappable: MockDataSourceNonMappableDefinition = MockDataSourceNonMappableDefinition()
}

class MockDataSourceDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = .black
    var imageName: String?
    var systemImageName: String? = "face.smiling"
    var key: String = "mockdatasource"
    var metricsKey: String = "mockdatasource"
    var name: String = NSLocalizedString("mockdatasource", comment: "mockdatasource data source display name")
    var fullName: String = NSLocalizedString("mock data source", comment: "mock data source data source full display name")
    var order: Int = 0
    var filterable: Filterable? = MockDataSourceFilterable()
}

class MockDataSourceFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSources.mockDataSource
    }

    var properties: [Marlin.DataSourceProperty] = [
        DataSourceProperty(name: "String", key: "stringProperty", type: .string),
        DataSourceProperty(name: "Date", key: "dateProperty", type: .date),
        DataSourceProperty(name: "Int", key: "intProperty", type: .int),
        DataSourceProperty(name: "Double", key: "doubleProperty", type: .double),
        DataSourceProperty(name: "Float", key: "floatProperty", type: .float),
        DataSourceProperty(name: "Enumeration", key: "enumerationProperty", type: .enumeration),
        DataSourceProperty(name: "Location", key: "locationProperty", type: .location),
        DataSourceProperty(name: "Latitude", key: "latitudeProperty", type: .latitude),
        DataSourceProperty(name: "Longitude", key: "longitudeProperty", type: .longitude),
        DataSourceProperty(name: "Boolean", key: "booleanProperty", type: .boolean)
    ]

    var defaultFilter: [Marlin.DataSourceFilterParameter] = []

    var defaultSort: [Marlin.DataSourceSortParameter] = []
}

class MockDataSource: DataSource {
    static var definition: any DataSourceDefinition {
        DataSources.mockDataSource
    }

    var itemKey: String { "itemKey" }
    
    var itemTitle: String { "itemTitle" }
    
    static var properties: [Marlin.DataSourceProperty] = [
        DataSourceProperty(name: "String", key: "stringProperty", type: .string),
        DataSourceProperty(name: "Date", key: "dateProperty", type: .date),
        DataSourceProperty(name: "Int", key: "intProperty", type: .int),
        DataSourceProperty(name: "Double", key: "doubleProperty", type: .double),
        DataSourceProperty(name: "Float", key: "floatProperty", type: .float),
        DataSourceProperty(name: "Enumeration", key: "enumerationProperty", type: .enumeration),
        DataSourceProperty(name: "Location", key: "locationProperty", type: .location),
        DataSourceProperty(name: "Latitude", key: "latitudeProperty", type: .latitude),
        DataSourceProperty(name: "Longitude", key: "longitudeProperty", type: .longitude),
        DataSourceProperty(name: "Boolean", key: "booleanProperty", type: .boolean)
    ]
    
    static var defaultSort: [Marlin.DataSourceSortParameter] = []
    
    static var defaultFilter: [Marlin.DataSourceFilterParameter] = []
    
    static var isMappable: Bool = true
    
    static var dataSourceName: String = "mockdatasource"
    
    static var fullDataSourceName: String = "mock data source"
    
    static var key: String = "mockdatasource"
    static var metricsKey: String = "mockdatasource"
    
    static var color: UIColor = UIColor.black
    
    static var imageName: String?
    
    static var systemImageName: String? = "face.smiling"
    
    var color: UIColor = UIColor.black
    
    static var imageScale: CGFloat = 0.5
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
    
    @objc var latitude: Double = 1.0
    
    @objc var longitude: Double = 1.0
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
    
    @objc var stringProperty: String = ""
    @objc var intProperty: Int = 0
    @objc var doubleProperty: Double = 0.0
    @objc var floatProperty: Float = 0.0
    @objc var enumerationProperty: String = MockEnum.Y.description
    @objc var locationProperty: String = ""
    @objc var dateProperty: Date = Date()
    @objc var booleanProperty: Bool = true
    @objc var latitudeProperty: Double = 0.0
    @objc var longitudeProperty: Double = 0.0
}

class MockDataSourceDefaultSortDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = .black
    var imageName: String?
    var systemImageName: String? = "face.smiling"
    var key: String = "mockdefaultsort"
    var metricsKey: String = "mockdefaultsort"
    var name: String = NSLocalizedString("mockdefaultsort", comment: "mockdatasource data source display name")
    var fullName: String = NSLocalizedString("mock default sort", comment: "mock data source data source full display name")
    var order: Int = 0
    var filterable: Filterable? = MockDataSourceDefaultSortFilterable()
}

class MockDataSourceDefaultSortFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSources.mockDataSourceDefaultSort
    }

    var properties: [Marlin.DataSourceProperty] = [
        DataSourceProperty(name: "String", key: "stringProperty", type: .string),
        DataSourceProperty(name: "Date", key: "dateProperty", type: .date),
        DataSourceProperty(name: "Int", key: "intProperty", type: .int)
    ]

    var defaultFilter: [Marlin.DataSourceFilterParameter] = [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(MockDataSourceDefaultSort.dateProperty), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last365Days)]

    var defaultSort: [Marlin.DataSourceSortParameter] = [
        DataSourceSortParameter(property: DataSourceProperty(name: "Date", key: "dateProperty", type: .date), ascending: true)
    ]
}

class MockDataSourceDefaultSort: DataSource {
    static var definition: any DataSourceDefinition = MockDataSourceDefaultSortDefinition()
    
    var itemKey: String { "itemKey" }
    
    var itemTitle: String { "itemTitle" }
    
    static var properties: [Marlin.DataSourceProperty] = [
        DataSourceProperty(name: "String", key: "stringProperty", type: .string),
        DataSourceProperty(name: "Date", key: "dateProperty", type: .date),
        DataSourceProperty(name: "Int", key: "intProperty", type: .int)
    ]
    
    static var defaultSort: [Marlin.DataSourceSortParameter] = [
        DataSourceSortParameter(property: DataSourceProperty(name: "Date", key: "dateProperty", type: .date), ascending: true)
    ]
    
    static var defaultFilter: [Marlin.DataSourceFilterParameter] = [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(MockDataSourceDefaultSort.dateProperty), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last365Days)]
    
    static var isMappable: Bool { definition.mappable }
    
    static var dataSourceName: String { definition.name }
    
    static var fullDataSourceName: String { definition.fullName }
    
    static var key: String { definition.key }
    static var metricsKey: String { definition.metricsKey }
    
    static var color: UIColor { definition.color }
    
    static var imageName: String? { definition.imageName }
    
    static var systemImageName: String? { definition.systemImageName }
    
    var color: UIColor { Self.definition.color }
    
    static var imageScale: CGFloat = 0.5
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
    
    @objc var latitude: Double = 1.0
    
    @objc var longitude: Double = 1.0
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
    
    @objc var stringProperty: String = ""
    @objc var intProperty: Int = 0
    @objc var doubleProperty: Double = 0.0
    @objc var floatProperty: Float = 0.0
    @objc var enumerationProperty: String = MockEnum.Y.description
    @objc var locationProperty: String = ""
    @objc var dateProperty: Date = Date()
    @objc var booleanProperty: Bool = true
}

class MockDataSourceNonMappableDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = .black
    var imageName: String? = "marlin_small"
    var systemImageName: String?
    var key: String = "mocknonmappable"
    var metricsKey: String = "mocknonmappable"
    var name: String = NSLocalizedString("mocknonmappable", comment: "mockdatasource data source display name")
    var fullName: String = NSLocalizedString("mock non mappable", comment: "mock data source data source full display name")
    var order: Int = 0
    var filterable: Filterable? = MockDataSourceNonMappableFilterable()
}

class MockDataSourceNonMappableFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSources.mockDataSourceNonMappable
    }

    var properties: [Marlin.DataSourceProperty] = [
        DataSourceProperty(name: "String", key: "stringProperty", type: .string),
        DataSourceProperty(name: "Date", key: "dateProperty", type: .date),
        DataSourceProperty(name: "Int", key: "intProperty", type: .int),
        DataSourceProperty(name: "Double", key: "doubleProperty", type: .double),
        DataSourceProperty(name: "Float", key: "floatProperty", type: .float),
        DataSourceProperty(name: "Enumeration", key: "enumerationProperty", type: .enumeration),
        DataSourceProperty(name: "Location", key: "locationProperty", type: .location),
        DataSourceProperty(name: "Date", key: "dateProperty", type: .date),
        DataSourceProperty(name: "Boolean", key: "booleanProperty", type: .boolean)
    ]

    var defaultFilter: [Marlin.DataSourceFilterParameter] = []

    var defaultSort: [Marlin.DataSourceSortParameter] = []
}

class MockDataSourceNonMappable: DataSource {
    static var definition: any DataSourceDefinition = MockDataSourceNonMappableDefinition()
    var itemKey: String { "itemKey" }
    
    var itemTitle: String { "itemTitle" }
    
    static var properties: [Marlin.DataSourceProperty] = [
        DataSourceProperty(name: "String", key: "stringProperty", type: .string),
        DataSourceProperty(name: "Date", key: "dateProperty", type: .date),
        DataSourceProperty(name: "Int", key: "intProperty", type: .int),
        DataSourceProperty(name: "Double", key: "doubleProperty", type: .double),
        DataSourceProperty(name: "Float", key: "floatProperty", type: .float),
        DataSourceProperty(name: "Enumeration", key: "enumerationProperty", type: .enumeration),
        DataSourceProperty(name: "Location", key: "locationProperty", type: .location),
        DataSourceProperty(name: "Date", key: "dateProperty", type: .date),
        DataSourceProperty(name: "Boolean", key: "booleanProperty", type: .boolean)
    ]
    
    static var defaultSort: [Marlin.DataSourceSortParameter] = []
    
    static var defaultFilter: [Marlin.DataSourceFilterParameter] = []
    
    static var isMappable: Bool { definition.mappable }
    
    static var dataSourceName: String { definition.name }
    
    static var fullDataSourceName: String { definition.fullName }
    
    static var key: String { definition.key }
    static var metricsKey: String { definition.metricsKey }
    
    static var color: UIColor { definition.color }
    
    static var imageName: String? { definition.imageName }
    
    static var systemImageName: String? { definition.systemImageName }
    
    var color: UIColor { Self.definition.color }
    
    static var imageScale: CGFloat = 0.5
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
    
    @objc var latitude: Double = 1.0
    
    @objc var longitude: Double = 1.0
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
    
    @objc var stringProperty: String = ""
    @objc var intProperty: Int = 0
    @objc var doubleProperty: Double = 0.0
    @objc var floatProperty: Float = 0.0
    @objc var enumerationProperty: String = MockEnum.Y.description
    @objc var locationProperty: String = ""
    @objc var dateProperty: Date = Date()
    @objc var booleanProperty: Bool = true
}
