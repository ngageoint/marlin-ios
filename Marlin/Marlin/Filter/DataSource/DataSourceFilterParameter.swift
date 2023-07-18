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
    
    init(property: DataSourceProperty, comparison: DataSourceFilterComparison, valueString: String? = nil, valueDate: Date? = nil, valueInt: Int? = nil, valueDouble: Double? = nil, valueLatitude: Double? = nil, valueLongitude: Double? = nil, valueMinLatitude: Double? = nil, valueMinLongitude: Double? = nil, valueMaxLatitude: Double? = nil, valueMaxLongitude: Double? = nil, windowUnits: DataSourceWindowUnits? = nil) {
        self.property = property
        self.comparison = comparison
        self.valueString = valueString
        self.valueDate = valueDate
        self.valueInt = valueInt
        self.valueDouble = valueDouble
        self.valueLatitude = valueLatitude
        self.valueLongitude = valueLongitude
        if let valueMinLatitude = valueMinLatitude, let valueMinLongitude = valueMinLongitude, let valueMaxLatitude = valueMaxLatitude, let valueMaxLongitude = valueMaxLongitude {
            self.valueBounds = MapBoundingBox(swCorner: (x: valueMinLongitude, y: valueMinLatitude), neCorner: (x: valueMaxLongitude, y: valueMaxLatitude))
        } else {
            self.valueBounds = nil
        }
        self.windowUnits = windowUnits
    }
    
    func display() -> String {
        var stringValue = ""
        switch (property.type) {
            
        case .string:
            if let valueString = valueString {
                stringValue = "**\(property.name)** \(comparison.rawValue) **\(valueString)**"
            }
        case .date:
            if comparison == .window, let windowUnits = windowUnits {
                stringValue = "**\(property.name)** within the **\(windowUnits.rawValue)**"
            } else if let valueDate = valueDate {
                stringValue = "**\(property.name)** \(comparison.rawValue) **\(valueDate.formatted())**"
            }
        case .int:
            if let valueInt = valueInt {
                stringValue = "**\(property.name)** \(comparison.rawValue) **\(valueInt)**"
            }
        case .float, .double:
            if let valueDouble = valueDouble {
                stringValue = "**\(property.name)** \(comparison.rawValue) **\(valueDouble)**"
            }
        case .boolean:
            if let valueInt = valueInt {
                stringValue = "**\(property.name)** \(comparison.rawValue) **\(valueInt == 0 ? "False" : "True")**"
            }
        case .enumeration:
            if let valueString = valueString {
                stringValue = "**\(property.name)** \(comparison.rawValue) **\(valueString)**"
            }
        case .location:
            if comparison == .nearMe {
                stringValue = "**\(property.name)** within **\(valueInt ?? 0)nm** of my location"
            } else if comparison == .closeTo {
                stringValue = "**\(property.name)** within **\(valueInt ?? 0)nm** of **\(CLLocationCoordinate2D(latitude: valueLatitude ?? 0.0, longitude: valueLongitude ?? 0.0).format())**"
            } else {
                stringValue = "**\(property.name)** within bounds of **\(valueBounds?.swCoordinate.format() ?? "")** and **\(valueBounds?.neCoordinate.format() ?? "")**"
            }
        case .latitude:
            stringValue = "**\(property.name)** \(comparison.rawValue) **\(valueString ?? "")**"
        case .longitude:
            stringValue = "**\(property.name)** \(comparison.rawValue) **\(valueString ?? "")**"
        }
        return stringValue
    }
    
    func toPredicate(dataSource: any DataSource.Type) -> NSPredicate? {
        var propertyAndComparison: String = "\(property.key) \(comparison.coreDataComparison())"
        if let subEntityKey = property.subEntityKey {
            propertyAndComparison = "ANY \(property.key).\(subEntityKey) \(comparison.coreDataComparison())"
        }
        
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
        } else if property.type == .int, let value = valueInt {
            return NSPredicate(format: "\(propertyAndComparison) %d", value)
        } else if property.type == .boolean, let value = valueInt {
            return NSPredicate(format: "\(propertyAndComparison) %d", value)
        } else if (property.type == .float || property.type == .double), let value = valueDouble {
            return NSPredicate(format: "\(propertyAndComparison) %f", value)
        } else if (property.type == .latitude), let value = valueLatitude {
            return NSPredicate(format: "\(propertyAndComparison) %f", value)
        } else if (property.type == .longitude), let value = valueLongitude {
            return NSPredicate(format: "\(propertyAndComparison) %f", value)
        } else if property.type == .enumeration, let value = valueString {
            if let queryValues = property.enumerationValues?[value], !queryValues.isEmpty {
                var valuePredicates: [NSPredicate] = []
                for queryValue in queryValues {
                    valuePredicates.append(NSPredicate(format: "\(propertyAndComparison) %@", queryValue))
                }
                return NSCompoundPredicate(orPredicateWithSubpredicates: valuePredicates)
            }
            
            return NSPredicate(format: "\(propertyAndComparison) %@", value)
        } else if property.type == .location {
            if comparison == .bounds {
                guard let bounds = valueBounds else {
                    return nil
                }
                if let dataSource = dataSource as? DataSourceLocation {
                    return type(of: dataSource).getBoundingPredicate(minLat: bounds.swCorner.y, maxLat: bounds.neCorner.y, minLon: bounds.swCorner.x, maxLon: bounds.neCorner.x)
                }
                return NSPredicate(format: "latitude <= %f AND latitude >= %f AND longitude <= %f AND longitude >= %f", bounds.neCorner.y, bounds.swCorner.y, bounds.neCorner.x, bounds.swCorner.x)
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
            
            if let metersPoint = SFGeometryUtils.degreesToMetersWith(x: longitude, andY: latitude), let x = metersPoint.x as? Double, let y = metersPoint.y as? Double {
                let southWest = SFGeometryUtils.metersToDegreesWith(x: x - metersDistance, andY: y - metersDistance)
                let northEast = SFGeometryUtils.metersToDegreesWith(x: x + metersDistance, andY: y + metersDistance)
                if let southWest = southWest, let northEast = northEast, let maxy = northEast.y, let miny = southWest.y, let minx = southWest.x, let maxx = northEast.x {
                    if let dataSource = dataSource as? DataSourceLocation {
                        return type(of: dataSource).getBoundingPredicate(minLat: miny.doubleValue, maxLat: maxy.doubleValue, minLon: minx.doubleValue, maxLon: maxx.doubleValue)
                    }
                    return NSPredicate(format: "latitude <= %f AND latitude >= %f AND longitude <= %f AND longitude >= %f", maxy.floatValue, miny.floatValue, maxx.floatValue, minx.floatValue)
                }
            }
        }
        return nil
    }
}
