//
//  GeoJSONExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/23.
//

import Foundation
import GeoJSON
import AnyCodable

protocol GeoJSONExportable: NSObject {
    var geoJson: String? { get }
    static var properties: [DataSourceProperty] { get }
    var sfGeometry: SFGeometry? { get }
}

extension GeoJSONExportable {
    var geoJsonFeature: Feature? {
        var geoJsonProperties: [String: AnyCodable] = [:]
        for property in Self.properties {
            if let value = self.value(forKey: property.key) {
                let codable = AnyCodable(value)
                geoJsonProperties[property.key] = codable
            }
        }
        var feature: Feature? = nil
        let sf = sfGeometry
        switch sf {
        case let point as SFPoint:
            if let x = point.x as? Double, let y = point.y as? Double {
                feature = Feature(geometry: .point(Point(longitude: x, latitude: y)), properties: geoJsonProperties)
            }
        case let line as SFLineString:
            if let lineString = line.toGeoJSON() {
                feature = Feature(geometry: .lineString(lineString), properties: geoJsonProperties)
            }
        case let polygon as SFPolygon:
            if let polygon = polygon.toGeoJSON() {
                feature = Feature(geometry: .polygon(polygon), properties: geoJsonProperties)
            }
        default:
            print("default")
        }
        return feature
    }
    
    var geoJson: String? {
        if let feature = geoJsonFeature, let json = try? JSONEncoder().encode(feature), let string = String(data: json, encoding: .utf8) {
            
            print(string)
            return string
        }
        
        return nil
    }
}

