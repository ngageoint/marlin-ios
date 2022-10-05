//
//  FilterBottomSheet.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI

class DataSourceFilter: Identifiable {
    let id = UUID()
    let dataSource: any DataSource.Type
    var filters: [DataSourceFilterParameter] = []
    
    init(dataSource: any DataSource.Type, filters: [DataSourceFilterParameter] = []) {
        self.dataSource = dataSource
        self.filters = filters
    }
    
    func addFilter(_ filter: DataSourceFilterParameter) {
        self.filters.append(filter)
        print("there are now this many filters \(self.filters)")
    }
}

enum DataSourceFilterComparison: String, CaseIterable, Identifiable, Codable {
    case equals = "="
    case notEquals = "!="
    case greaterThan = ">"
    case greaterThanEqual = ">="
    case lessThan = "<"
    case lessThanEqual = "<="
    case contains = "contains"
    case notContains = "not contains"
    case startsWith = "starts with"
    case endsWith = "ends with"
    case window = "within"
    var id: String { rawValue }
    
    static func dateSubset() -> [DataSourceFilterComparison] {
        return [.window, .equals, .notEquals, .greaterThan, .greaterThanEqual, .lessThan, .lessThanEqual]
    }
    
    static func numberSubset() -> [DataSourceFilterComparison] {
        return [.equals, .notEquals, .greaterThan, .greaterThanEqual, .lessThan, .lessThanEqual]
    }
    
    static func stringSubset() -> [DataSourceFilterComparison] {
        return [.equals, .notEquals, .contains, .notContains, .startsWith, .endsWith]
    }
    
    static func enumerationSubset() -> [DataSourceFilterComparison] {
        return [.equals, .notEquals]
    }
    
    func coreDataComparison() -> String {
        switch(self) {
        case .equals:
            return "=="
        case .contains:
            return "contains[cd]"
        case .notContains:
            return "not contains[cd]"
        case .startsWith:
            return "beginswith[cd]"
        case .endsWith:
            return "endswith[cd]"
        case .window:
            return ">="
        default:
            return rawValue
        }
    }
}

enum DataSourceWindowUnits: String, CaseIterable, Identifiable, Codable {
    case last30Days = "last 30 days"
    case last7Days = "last 7 days"
    case last365Days = "last 365 days"
    
    var id: String { rawValue }
    
    func numberOfDays() -> Int {
        switch (self) {
        case .last7Days:
            return 7
        case .last30Days:
            return 30
        case .last365Days:
            return 365
        }
    }
}

struct DataSourceSortParameter: Identifiable, Hashable, Codable {
    static func == (lhs: DataSourceSortParameter, rhs: DataSourceSortParameter) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    let property: DataSourceProperty
    let ascending: Bool
    let section: Bool
    
    init(property: DataSourceProperty, ascending: Bool) {
        self.property = property
        self.ascending = ascending
        self.section = false
    }
    
    init(property: DataSourceProperty, ascending: Bool, section: Bool) {
        self.property = property
        self.ascending = ascending
        self.section = section
    }
    
    func toNSSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: property.key, ascending: ascending)
    }
}

struct DataSourceSort: Identifiable, Hashable, Codable {
    static func == (lhs: DataSourceSort, rhs: DataSourceSort) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    var sortProperties: [DataSourceSortParameter] = []
    
    func toNSSortDescriptors() -> [NSSortDescriptor] {
        var descriptors: [NSSortDescriptor] = []
        for sortProperty in sortProperties {
            descriptors.append(sortProperty.toNSSortDescriptor())
        }
        return descriptors
    }
}

struct DataSourceFilterParameter: Identifiable, Hashable, Codable {
    static func == (lhs: DataSourceFilterParameter, rhs: DataSourceFilterParameter) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    let property: DataSourceProperty
    let valueString: String?
    let valueDate: Date?
    let valueInt: Int?
    let valueDouble: Double?
    let windowUnits: DataSourceWindowUnits?
    let comparison: DataSourceFilterComparison
    
    init(property: DataSourceProperty, comparison: DataSourceFilterComparison, valueString: String? = nil, valueDate: Date? = nil, valueInt: Int? = nil, valueDouble: Double? = nil, windowUnits: DataSourceWindowUnits? = nil) {
        self.property = property
        self.comparison = comparison
        self.valueString = valueString
        self.valueDate = valueDate
        self.valueInt = valueInt
        self.valueDouble = valueDouble
        self.windowUnits = windowUnits
    }
    
    func valueToString() -> String {
        if let valueString = valueString {
            return valueString
        } else if let valueInt = valueInt {
            return String(describing: valueInt)
        } else if let valueDouble = valueDouble {
            return String(describing: valueDouble)
        }
        
        return ""
    }
    
    func toPredicate() -> NSPredicate? {
        if property.type == .string, let value = valueString {
            return NSPredicate(format: "\(property.key) \(comparison.coreDataComparison()) %@", value)
        } else if property.type == .date {
            
            if comparison == .window {
                if let value = windowUnits {
                    var calendar = Calendar.current
                    calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
                    
                    // Get today's beginning & end
                    let start = calendar.startOfDay(for: Date())
                    if let dateFrom = calendar.date(byAdding: .day, value: -value.numberOfDays(), to: start) {
                        return NSPredicate(format: "\(property.key) \(comparison.coreDataComparison()) %@", dateFrom as NSDate)
                    }
                }
            } else if let value = valueDate {
                var calendar = Calendar.current
                calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
                
                // Get today's beginning & end
                let dateFrom = calendar.startOfDay(for: value)
                
                if comparison == .equals {
                    
                    guard let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom) else {
                        return nil
                    }
                    // Set predicate as date being today's date
                    let fromPredicate = NSPredicate(format: "\(property.key) >= %@", dateFrom as NSDate)
                    let toPredicate = NSPredicate(format: "\(property.key) < %@", dateTo as NSDate)
                    return NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
                } else {
                    return NSPredicate(format: "\(property.key) \(comparison.coreDataComparison()) %@", dateFrom as NSDate)
                }
            }
        } else if property.type == .int, let value = valueInt {
            return NSPredicate(format: "\(property.key) \(comparison.coreDataComparison()) %d", value)
        } else if (property.type == .float || property.type == .double), let value = valueDouble {
            return NSPredicate(format: "\(property.key) \(comparison.coreDataComparison()) %f", value)
        } else if property.type == .enumeration, let value = valueString {
            if let queryValues = property.enumerationValues?[value], !queryValues.isEmpty {
                var valuePredicates: [NSPredicate] = []
                for queryValue in queryValues {
                    valuePredicates.append(NSPredicate(format: "\(property.key) \(comparison.coreDataComparison()) %@", queryValue))
                }
                return NSCompoundPredicate(orPredicateWithSubpredicates: valuePredicates)
            }
            
            return NSPredicate(format: "\(property.key) \(comparison.coreDataComparison()) %@", value)
        }
        return nil
    }
}

struct FilterBottomSheet: View {
    @Binding var dataSources: [DataSourceItem]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach($dataSources.filter({ item in
                    item.showOnMap.wrappedValue
                }).sorted(by: { item1, item2 in
                    item1.order.wrappedValue < item2.order.wrappedValue
                })) { $dataSourceItem in
                    FilterBottomSheetRow(dataSourceItem: $dataSourceItem)
                }
                .background(Color.surfaceColor)
            }
            .background(Color.backgroundColor)
            
        }
        .navigationTitle("Filters")
        .background(Color.backgroundColor)
    }
}
