//
//  GeoJSONExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/23.
//

import Foundation
import GeoJSON
import AnyCodable
import sf_ios

protocol GeoJSONExportable: Identifiable, Equatable, DataSource {
    static var definition: any DataSourceDefinition { get }
    var itemKey: String { get }
//    var key: String { get }
    var geoJson: String? { get }
    static var properties: [DataSourceProperty] { get }
    var sfGeometry: SFGeometry? { get }
    var uniqueId: String { get }
}
extension GeoJSONExportable {
    var key: String {
        Self.definition.key
    }
    var id: String {
        uniqueId
    }
    var uniqueId: String {
        return "\(key)--\(itemKey)"
    }
    var geoJsonFeatures: [Feature] {
        var geoJsonProperties: [String: AnyCodable] = [:]

        geoJsonProperties["marlin_data_source"] = AnyCodable(Self.definition.key)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        if let encodable = self as? Encodable, let data = encodable.dictionary {
            for (key, value) in data {
                geoJsonProperties[key] = AnyCodable(value)
            }
        } else {

            for property in Self.properties {
                if let gjObject = self as? NSObject, let value = gjObject.value(forKey: property.key) {
                    switch property.type {
                    case .location:
                        print("ignore")
                    default:
                        let codable = AnyCodable(value)
                        geoJsonProperties[property.key] = codable
                    }

                }
            }
        }
        return getFeature(simpleFeature: sfGeometry, geoJsonProperties: geoJsonProperties)
    }
    
    func getFeature(simpleFeature: SFGeometry?, geoJsonProperties: [String: AnyCodable]) -> [Feature] {
        var features: [Feature] = []
        switch simpleFeature {
        case let point as SFPoint:
            if let x = point.x as? Double, let y = point.y as? Double {
                features.append(
                    Feature(geometry: .point(Point(longitude: x, latitude: y)), properties: geoJsonProperties)
                )
            }
        case let line as SFLineString:
            if let lineString = line.toGeoJSON() {
                features.append(Feature(geometry: .lineString(lineString), properties: geoJsonProperties))
            }
        case let polygon as SFPolygon:
            if let polygon = polygon.toGeoJSON() {
                features.append(Feature(geometry: .polygon(polygon), properties: geoJsonProperties))
            }
        case let collection as SFGeometryCollection:
            for geometry in collection.geometries {
                if let geometry = geometry as? SFGeometry {
                    features.append(
                        contentsOf: getFeature(simpleFeature: geometry, geoJsonProperties: geoJsonProperties)
                    )
                }
            }
        default:
            print("default")
        }
        return features
    }
    
    var geoJson: String? {
        let features = geoJsonFeatures
        if features.isEmpty {
            return nil
        }
        let collection = FeatureCollection(features: features)
        if let json = try? JSONEncoder().encode(collection), let string = String(data: json, encoding: .utf8) {
            
            print(string)
            return string
        }
        
        return nil
    }
}
