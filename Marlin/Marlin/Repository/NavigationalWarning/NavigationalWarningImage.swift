//
//  NavigationalWarningImage.swift
//  Marlin
//
//  Created by Daniel Barela on 2/29/24.
//

import Foundation
import sf_ios
import MapKit

class NavigationalWarningImage: DataSourceImage {
    var feature: SFGeometry?
    var navigationalWarning: NavigationalWarningModel

    static var dataSource: any DataSourceDefinition = DataSources.navWarning

    init(navigationalWarning: NavigationalWarningModel) {
        self.navigationalWarning = navigationalWarning
        feature = navigationalWarning.sfGeometry
    }

    func image(
        context: CGContext?,
        zoom: Int,
        tileBounds: MapBoundingBox,
        tileSize: Double
    ) -> [UIImage] {
        var images: [UIImage] = []
        if let locations = navigationalWarning.locations {
            for location in locations {
                if let wkt = location["wkt"] {
                    var distance: Double?
                    if let distanceString = location["distance"] {
                        distance = Double(distanceString)
                    }

                    let shape = MKShape.fromWKT(wkt: wkt, distance: distance)

                    if let point = shape as? MKPointAnnotation {
                        if let distance = distance {
                            distanceCircle(
                                point: point,
                                distance: distance,
                                zoomLevel: zoom,
                                tileBounds3857: tileBounds
                            )
                        }
                        images.append(
                            contentsOf: defaultMapImage(
                                marker: false,
                                zoomLevel: zoom,
                                pointCoordinate: navigationalWarning.coordinate,
                                tileBounds3857: tileBounds,
                                context: context,
                                tileSize: 512.0))
                    } else if let polygon = shape as? MKPolygon {
                        polygonImage(polygon: polygon, zoomLevel: zoom, tileBounds3857: tileBounds)
                    } else if let lineShape = shape as? MKGeodesicPolyline {
                        polylineImage(lineShape: lineShape, zoomLevel: zoom, tileBounds3857: tileBounds)
                    } else if let circle = shape as? MKCircle {
                        circleImage(circle: circle, zoomLevel: zoom, tileBounds3857: tileBounds)
                    }
                }
            }
        }

        return images
    }

    func distanceCircle(
        point: MKPointAnnotation,
        distance: Double,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox,
        context: CGContext? = nil
    ) {
        let coordinate = point.coordinate
        let circleCoordinates = coordinate.circleCoordinates(radiusMeters: distance)
        let path = UIBezierPath()

        var pixel = circleCoordinates[0].toPixel(
            zoomLevel: zoomLevel,
            tileBounds3857: tileBounds3857,
            tileSize: TILE_SIZE)
        path.move(to: pixel)
        for circleCoordinate in circleCoordinates {
            pixel = circleCoordinate.toPixel(
                zoomLevel: zoomLevel,
                tileBounds3857: tileBounds3857,
                tileSize: TILE_SIZE)
            path.addLine(to: pixel)
        }
        path.lineWidth = 4
        path.close()
        NavigationalWarning.color.withAlphaComponent(0.3).setFill()
        NavigationalWarning.color.setStroke()
        path.fill()
        path.stroke()
    }

    func polygonImage(
        polygon: MKPolygon,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox
    ) {
        let polyline = polygon.toGeodesicPolyline()
        let path = UIBezierPath()
        var first = true

        for point in UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount) {

            let pixel = point.coordinate.toPixel(
                zoomLevel: zoomLevel,
                tileBounds3857: tileBounds3857,
                tileSize: TILE_SIZE,
                canCross180thMeridian: polyline.boundingMapRect.spans180thMeridian)
            if first {
                path.move(to: pixel)
                first = false
            } else {
                path.addLine(to: pixel)
            }

        }

        path.lineWidth = 4
        path.close()
        NavigationalWarning.color.withAlphaComponent(0.3).setFill()
        NavigationalWarning.color.setStroke()
        path.fill()
        path.stroke()
    }

    func polylineImage(
        lineShape: MKPolyline,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox
    ) {
        let path = UIBezierPath()
        var first = true
        let points = lineShape.points()

        for point in UnsafeBufferPointer(start: points, count: lineShape.pointCount) {

            let pixel = point.coordinate.toPixel(
                zoomLevel: zoomLevel,
                tileBounds3857: tileBounds3857,
                tileSize: TILE_SIZE)
            if first {
                path.move(to: pixel)
                first = false
            } else {
                path.addLine(to: pixel)
            }

        }

        path.lineWidth = 4
        NavigationalWarning.color.setStroke()
        path.stroke()
    }

    func circleImage(
        circle: MKCircle,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox
    ) {
        let circleCoordinates = circle.coordinate.circleCoordinates(radiusMeters: circle.radius)
        let path = UIBezierPath()

        var pixel = circleCoordinates[0].toPixel(
            zoomLevel: zoomLevel,
            tileBounds3857: tileBounds3857,
            tileSize: TILE_SIZE)
        path.move(to: pixel)
        for circleCoordinate in circleCoordinates {
            pixel = circleCoordinate.toPixel(
                zoomLevel: zoomLevel,
                tileBounds3857: tileBounds3857,
                tileSize: TILE_SIZE)
            path.addLine(to: pixel)
        }
        path.lineWidth = 4
        path.close()
        NavigationalWarning.color.withAlphaComponent(0.3).setFill()
        NavigationalWarning.color.setStroke()
        path.fill()
        path.stroke()

        // put a dot in the middle
        pixel = circle.coordinate.toPixel(
            zoomLevel: zoomLevel,
            tileBounds3857: tileBounds3857,
            tileSize: TILE_SIZE)
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * 0.5
        let centerDot = UIBezierPath(
            arcCenter: pixel,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true)
        centerDot.lineWidth = 0.5
        centerDot.stroke()
        NavigationalWarning.color.setFill()
        centerDot.fill()
    }
}
