//
//  DataSourceFilterComparison.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation

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
    case closeTo = "near"
    case nearMe = "near me"
    case bounds = "bounded by"
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
    
    static func locationSubset() -> [DataSourceFilterComparison] {
        return [.nearMe, .closeTo, .bounds]
    }
    
    static func latitudeSubset() -> [DataSourceFilterComparison] {
        return numberSubset()
    }
    
    static func longitudeSubset() -> [DataSourceFilterComparison] {
        return numberSubset()
    }
    
    static func booleanSubset() -> [DataSourceFilterComparison] {
        return [.equals, .notEquals]
    }
    
    func coreDataComparison() -> String {
        switch self {
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
        case .notEquals, .greaterThan, .greaterThanEqual, .lessThan, .lessThanEqual:
            return rawValue
        default:
            return "=="
        }
    }
}
