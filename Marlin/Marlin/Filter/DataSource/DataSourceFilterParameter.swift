//
//  DataSourceFilterParameter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation
import CoreLocation
import mgrs_ios
import sf_proj_ios

extension Array where Element == DataSourceFilterParameter {
    func getCacheKey() -> String {
        return self.reduce("") { currentKey, param in
            currentKey + param.display()
        }
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
    let valueLatitude: Double?
    let valueLongitude: Double?
    let valueBounds: MapBoundingBox?
    let windowUnits: DataSourceWindowUnits?
    let comparison: DataSourceFilterComparison
    
    init(
        property: DataSourceProperty,
        comparison: DataSourceFilterComparison,
        valueString: String? = nil,
        valueDate: Date? = nil,
        valueInt: Int? = nil,
        valueDouble: Double? = nil,
        valueLatitude: Double? = nil,
        valueLongitude: Double? = nil,
        valueMinLatitude: Double? = nil,
        valueMinLongitude: Double? = nil,
        valueMaxLatitude: Double? = nil,
        valueMaxLongitude: Double? = nil,
        windowUnits: DataSourceWindowUnits? = nil) {
        self.property = property
        self.comparison = comparison
        self.valueString = valueString
        self.valueDate = valueDate
        self.valueInt = valueInt
        self.valueDouble = valueDouble
        self.valueLatitude = valueLatitude
        self.valueLongitude = valueLongitude
        if let valueMinLatitude = valueMinLatitude, 
            let valueMinLongitude = valueMinLongitude,
            let valueMaxLatitude = valueMaxLatitude,
            let valueMaxLongitude = valueMaxLongitude {
            self.valueBounds = MapBoundingBox(
                swCorner: (x: valueMinLongitude, y: valueMinLatitude),
                neCorner: (x: valueMaxLongitude, y: valueMaxLatitude))
        } else {
            self.valueBounds = nil
        }
        self.windowUnits = windowUnits
    }
    
    func display() -> String {
        var stringValue = ""
        switch property.type {
            
        case .string:
            stringValue = stringDisplay() ?? ""
        case .date:
            stringValue = dateDisplay() ?? ""
        case .int:
            stringValue = intDisplay() ?? ""
        case .float, .double:
            stringValue = doubleDisplay() ?? ""
        case .boolean:
            stringValue = boolDisplay() ?? ""
        case .enumeration:
            stringValue = enumDisplay() ?? ""
        case .location:
            stringValue = locationDisplay() ?? ""
        case .latitude:
            stringValue = latitudeDisplay()
        case .longitude:
            stringValue = longitudeDisplay()
        }
        return stringValue
    }

    func stringDisplay() -> String? {
        if let valueString = valueString {
            return "**\(property.name)** \(comparison.rawValue) **\(valueString)**"
        }
        return nil
    }

    func dateDisplay() -> String? {
        if comparison == .window, let windowUnits = windowUnits {
            return "**\(property.name)** within the **\(windowUnits.rawValue)**"
        } else if let valueDate = valueDate {
            return "**\(property.name)** \(comparison.rawValue) **\(valueDate.formatted())**"
        }
        return nil
    }

    func intDisplay() -> String? {
        if let valueInt = valueInt {
            return "**\(property.name)** \(comparison.rawValue) **\(valueInt)**"
        }
        return nil
    }

    func doubleDisplay() -> String? {
        if let valueDouble = valueDouble {
            return "**\(property.name)** \(comparison.rawValue) **\(valueDouble)**"
        }
        return nil
    }

    func boolDisplay() -> String? {
        if let valueInt = valueInt {
            return "**\(property.name)** \(comparison.rawValue) **\(valueInt == 0 ? "False" : "True")**"
        }
        return nil
    }

    func enumDisplay() -> String? {
        if let valueString = valueString {
            return "**\(property.name)** \(comparison.rawValue) **\(valueString)**"
        }
        return nil
    }

    func locationDisplay() -> String? {
        if comparison == .nearMe {
            return "**\(property.name)** within **\(valueInt ?? 0)nm** of my location"
        } else if comparison == .closeTo {
            return """
                    **\(property.name)** within **\(valueInt ?? 0)nm** \
                    of **\(CLLocationCoordinate2D(latitude: valueLatitude ?? 0.0,
                    longitude: valueLongitude ?? 0.0).format())**
                """
        } else {
            return """
                    **\(property.name)** within bounds of **\
                    \(valueBounds?.swCoordinate.format() ?? "")** and \
                    **\(valueBounds?.neCoordinate.format() ?? "")**
                """
        }
    }

    func latitudeDisplay() -> String {
        return "**\(property.name)** \(comparison.rawValue) **\(valueString ?? "")**"
    }

    func longitudeDisplay() -> String {
        return "**\(property.name)** \(comparison.rawValue) **\(valueString ?? "")**"
    }

    func toPredicate(
        dataSource: Filterable? = nil,
        boundsPredicateBuilder: ((MapBoundingBox) -> NSPredicate)? = nil
    ) -> NSPredicate? {
//        guard let dataSource = dataSource else {
//            return nil
//        }
        return DataSourcePredicateBuilder(
            property: property,
            comparison: comparison,
            filterable: dataSource,
            boundsPredicateBuilder: boundsPredicateBuilder,
            valueString: valueString,
            valueDate: valueDate,
            valueInt: valueInt,
            valueDouble: valueDouble,
            valueLatitude: valueLatitude,
            valueLongitude: valueLongitude,
            valueBounds: valueBounds,
            windowUnits: windowUnits)
            .toPredicate()
    }
}
