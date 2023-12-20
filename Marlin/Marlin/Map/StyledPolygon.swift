//
//  StyledPolygon.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit

@objc class StyledPolygon: MKPolygon, OverlayRenderable {
    var renderer: MKOverlayRenderer {
        let renderer = MKPolygonRenderer(polygon: self)
        renderer.fillColor = fillColor
        renderer.strokeColor = lineColor
        renderer.lineWidth = lineWidth
        return renderer
    }
    
    @objc public var lineColor: UIColor = .black
    @objc public var lineWidth: CGFloat = 1.0
    @objc public var fillColor: UIColor?
    
    @objc static func generate(coordinates: [[[NSNumber]]]) -> StyledPolygon {
        // exterior polygon
        let exteriorPolygonCoordinates = coordinates[0]
        var interiorPolygonCoordinates: [[[NSNumber]]] = []
        
        var exteriorMapCoordinates: [CLLocationCoordinate2D] = []
        for point in exteriorPolygonCoordinates {
            exteriorMapCoordinates.append(
                CLLocationCoordinate2D(latitude: point[1].doubleValue, longitude: point[0].doubleValue))
        }
        
        // interior polygons
        var interiorPolygons: [MKPolygon] = []
        if coordinates.count > 1 {
            interiorPolygonCoordinates.append(contentsOf: coordinates)
            interiorPolygonCoordinates.remove(at: 0)
            let recursePolygon = StyledPolygon.generate(coordinates: interiorPolygonCoordinates)
            interiorPolygons.append(recursePolygon)
        }
        
        let exteriorPolygon: StyledPolygon = !interiorPolygons.isEmpty ? StyledPolygon(
            coordinates: exteriorMapCoordinates,
            count: exteriorPolygonCoordinates.count,
            interiorPolygons: interiorPolygons) : 
        StyledPolygon(
            coordinates: exteriorMapCoordinates,
            count: exteriorPolygonCoordinates.count)

        return exteriorPolygon
    }
    
    @objc static func create(polygon: MKPolygon) -> StyledPolygon {
        let styledPolygon = StyledPolygon(points: polygon.points(), count: polygon.pointCount)
        styledPolygon.title = polygon.title
        styledPolygon.subtitle = polygon.subtitle
        return styledPolygon
    }
    
    @objc public func setLineColor(hex: String, alpha: CGFloat = 1.0) {
        self.lineColor = .label
//        self.lineColor = UIColor(hex: hex)?.withAlphaComponent(alpha) ?? self.lineColor
    }
    
    @objc public func setFillColor(hex: String, alpha: CGFloat = 1.0) {
        self.lineColor = .label
//        self.fillColor = UIColor(hex: hex)?.withAlphaComponent(alpha) ?? self.fillColor
    }
    
}
