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

    func stringPredicate() -> NSPredicate? {
        if let value = valueString {
            return NSPredicate(format: "\(property.key) \(comparison.coreDataComparison()) %@", value)
        }
        return nil
    }

    func datePredicate(propertyAndComparison: String) -> NSPredicate? {
        if comparison == .window {
            if let value = windowUnits {
                var calendar = Calendar.current
                calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone

                // Get today's beginning & end
                let start = calendar.startOfDay(for: Date())
                if let dateFrom = calendar.date(byAdding: .day, value: -value.numberOfDays(), to: start) {
                    return NSPredicate(format: "\(propertyAndComparison) %@", dateFrom as NSDate)
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
                return NSPredicate(format: "\(propertyAndComparison) %@", dateFrom as NSDate)
            }
        }
        return nil
    }

    func intPredicate(propertyAndComparison: String) -> NSPredicate? {
        if let value = valueInt {
            return NSPredicate(format: "\(propertyAndComparison) %d", value)
        }
        return nil
    }

    func boolPredicate(propertyAndComparison: String) -> NSPredicate? {
        if let value = valueInt {
            return NSPredicate(format: "\(propertyAndComparison) %d", value)
        }
        return nil
    }

    func doublePredicate(propertyAndComparison: String) -> NSPredicate? {
        if let value = valueDouble {
            return NSPredicate(format: "\(propertyAndComparison) %f", value)
        }
        return nil
    }

    func latitudePredicate(propertyAndComparison: String) -> NSPredicate? {
        if let value = valueLatitude {
            return NSPredicate(format: "\(propertyAndComparison) %f", value)
        }
        return nil
    }

    func longitudePredicate(propertyAndComparison: String) -> NSPredicate? {
        if let value = valueLongitude {
            return NSPredicate(format: "\(propertyAndComparison) %f", value)
        }
        return nil
    }

    func enumPredicate(propertyAndComparison: String) -> NSPredicate? {
        if let value = valueString {
            if let queryValues = property.enumerationValues?[value], !queryValues.isEmpty {
                var valuePredicates: [NSPredicate] = []
                for queryValue in queryValues {
                    valuePredicates.append(NSPredicate(format: "\(propertyAndComparison) %@", queryValue))
                }
                return NSCompoundPredicate(orPredicateWithSubpredicates: valuePredicates)
            }

            return NSPredicate(format: "\(propertyAndComparison) %@", value)
        }
        return nil
    }

    func locationPredicate(dataSource: Filterable) -> NSPredicate? {
        if comparison == .bounds {
            return boundsPredicate(dataSource: dataSource)
        }
        var centralLongitude: Double?
        var centralLatitude: Double?

        if comparison == .nearMe {
            if let lastLocation = LocationManager.shared().lastLocation {
                centralLongitude = lastLocation.coordinate.longitude
                centralLatitude = lastLocation.coordinate.latitude
            }
        } else if comparison == .closeTo {
            centralLongitude = valueLongitude
            centralLatitude = valueLatitude
        }

        guard let distance = valueInt, let latitude = centralLatitude, let longitude = centralLongitude else {
            NSLog("Nothing to use as location predicate")
            return nil
        }

        let nauticalMilesMeasurement = NSMeasurement(doubleValue: Double(distance), unit: UnitLength.nauticalMiles)
        let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
        let metersDistance = metersMeasurement.value

        if let metersPoint = SFGeometryUtils.degreesToMetersWith(x: longitude, andY: latitude),
            let x = metersPoint.x as? Double,
           let y = metersPoint.y as? Double {
            let southWest = SFGeometryUtils.metersToDegreesWith(x: x - metersDistance, andY: y - metersDistance)
            let northEast = SFGeometryUtils.metersToDegreesWith(x: x + metersDistance, andY: y + metersDistance)
            if let southWest = southWest,
                let northEast = northEast,
               let maxy = northEast.y,
               let miny = southWest.y,
               let minx = southWest.x,
               let maxx = northEast.x {
                if let dataSource = dataSource as? Locatable.Type {
                    return dataSource.getBoundingPredicate(
                        minLat: miny.doubleValue,
                        maxLat: maxy.doubleValue,
                        minLon: minx.doubleValue,
                        maxLon: maxx.doubleValue)
                }
                return nil
            }
        }
        return nil
    }

    func boundsPredicate(dataSource: Filterable) -> NSPredicate? {
        guard let bounds = valueBounds else {
            return nil
        }
        if let dataSource = dataSource.locatableClass {
            return dataSource.getBoundingPredicate(
                minLat: bounds.swCorner.y,
                maxLat: bounds.neCorner.y,
                minLon: bounds.swCorner.x,
                maxLon: bounds.neCorner.x)
        }
        return nil
    }

    func propertyAndComparison() -> String {
        var propertyAndComparison: String = "\(property.key) \(comparison.coreDataComparison())"
        if let subEntityKey = property.subEntityKey {
            propertyAndComparison = "ANY \(property.key).\(subEntityKey) \(comparison.coreDataComparison())"
        }
        return propertyAndComparison
    }

    func toPredicate(dataSource: Filterable?) -> NSPredicate? {
        guard let dataSource = dataSource else {
            return nil
        }
        if property.type == .string {
            return stringPredicate()
        } else if property.type == .date {
            return datePredicate(propertyAndComparison: propertyAndComparison())
        } else if property.type == .int {
            return intPredicate(propertyAndComparison: propertyAndComparison())
        } else if property.type == .boolean {
            return boolPredicate(propertyAndComparison: propertyAndComparison())
        } else if property.type == .float || property.type == .double {
            return doublePredicate(propertyAndComparison: propertyAndComparison())
        } else if property.type == .latitude {
            return latitudePredicate(propertyAndComparison: propertyAndComparison())
        } else if property.type == .longitude {
            return longitudePredicate(propertyAndComparison: propertyAndComparison())
        } else if property.type == .enumeration {
            return enumPredicate(propertyAndComparison: propertyAndComparison())
        } else if property.type == .location {
            return locationPredicate(dataSource: dataSource)
        }
        return nil
    }
}
