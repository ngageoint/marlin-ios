//
//  NavigationalWarning+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import CoreLocation
import OSLog
import MapKit
import GeoJSON

struct NavigationalWarningPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case broadcastWarn = "broadcast-warn"
    }
    let broadcastWarn: [NavigationalWarningModel]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        broadcastWarn = try container.decode(
            [Throwable<NavigationalWarningModel>].self,
            forKey: .broadcastWarn
        ).compactMap { try? $0.result.get() }
    }
}

// swiftlint:disable type_body_length
struct NavigationalWarningModel: Codable, Hashable, Identifiable, Bookmarkable, GeoJSONExportable, Locatable {
    static var definition: any DataSourceDefinition = DataSources.navWarning

    var canBookmark: Bool = false
    var id: String { self.itemKey }
    var itemTitle: String {
        return """
        \(self.navAreaName) \(String(self.msgNumber ?? 0))/\(String(self.msgYear ?? 0)) (\(self.subregion ?? ""))
        """
    }
    var itemKey: String {
        return "\(msgYear ?? 0)--\(msgNumber ?? 0)--\(navArea)"
    }
    var primaryKey: String {
        return "\(self.navArea) \(self.msgNumber ?? -1)/\(self.msgYear ?? -1)"
    }

    var navAreaName: String {
        if let navAreaEnum = NavigationalWarningNavArea.fromId(id: navArea) {
            return navAreaEnum.display
        }
        return ""
    }

    var dateString: String? {
        if let date = issueDate {
            return NavigationalWarning.dateFormatter.string(from: date)
        }
        return nil
    }

    var cancelDateString: String? {
        if let date = cancelDate {
            return NavigationalWarning.dateFormatter.string(from: date)
        }
        return nil
    }

    static let apiToDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddHHmm'Z' MMM yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    var coordinate: CLLocationCoordinate2D {
        if let locations = locations, !locations.isEmpty, let latitude = latitude, let longitude = longitude {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return kCLLocationCoordinate2DInvalid
    }

    var coordinateRegion: MKCoordinateRegion? {
        if let locations = locations,
           !locations.isEmpty,
           let maxLatitude = maxLatitude,
           let minLatitude = minLatitude,
           let maxLongitude = maxLongitude,
           let minLongitude = minLongitude,
           let latitude = latitude,
           let longitude = longitude {
            var latitudeDelta = maxLatitude - minLatitude
            var longitudeDelta = maxLongitude - minLongitude

            if latitudeDelta == 0.0 {
                latitudeDelta = 0.5
            }
            if longitudeDelta == 0.0 {
                longitudeDelta = 0.5
            }
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude),
                span: MKCoordinateSpan(
                    latitudeDelta: latitudeDelta,
                    longitudeDelta: longitudeDelta))
        }
        return nil
    }

    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case cancelMsgNumber
        case authority
        case cancelDate
        case cancelMsgYear
        case cancelNavArea
        case issueDate
        case msgNumber
        case msgYear
        case navArea
        case status
        case subregion
        case text
    }
    
    var cancelMsgNumber: Int?
    var authority: String?
    var cancelDate: Date?
    var cancelMsgYear: Int?
    var cancelNavArea: String?
    var issueDate: Date?
    var msgNumber: Int?
    var msgYear: Int?
    var navArea: String
    var status: String?
    var subregion: String?
    var text: String?
    var locations: [[String: String]]?
    var latitude: Double?
    var longitude: Double?
    var maxLatitude: Double?
    var minLatitude: Double?
    var maxLongitude: Double?
    var minLongitude: Double?

    init(navArea: String) {
        self.navArea = navArea
        self.canBookmark = false
        self.latitude = kCLLocationCoordinate2DInvalid.latitude
        self.longitude = kCLLocationCoordinate2DInvalid.longitude
    }

    init(navigationalWarning: NavigationalWarning) {
        self.cancelMsgNumber = Int(navigationalWarning.cancelMsgNumber)
        self.authority = navigationalWarning.authority
        self.cancelDate = navigationalWarning.cancelDate
        self.cancelMsgYear = Int(navigationalWarning.cancelMsgYear)
        self.cancelNavArea = navigationalWarning.cancelNavArea
        self.issueDate = navigationalWarning.issueDate
        self.msgNumber = Int(navigationalWarning.msgNumber)
        self.msgYear = Int(navigationalWarning.msgYear)
        self.navArea = navigationalWarning.navArea ?? ""
        self.status = navigationalWarning.status
        self.subregion = navigationalWarning.subregion
        self.text = navigationalWarning.text
        self.locations = navigationalWarning.locations
        self.latitude = navigationalWarning.latitude
        self.longitude = navigationalWarning.longitude
        self.maxLatitude = navigationalWarning.maxLatitude
        self.minLatitude = navigationalWarning.minLatitude
        self.maxLongitude = navigationalWarning.maxLongitude
        self.minLongitude = navigationalWarning.minLongitude
    }

    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {

            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)

            if let model = try? decoder.decode(NavigationalWarningModel.self, from: jsonData) {
                self = model
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawMsgYear = try? values.decode(Int.self, forKey: .msgYear)
        let rawMsgNumber = try? values.decode(Int.self, forKey: .msgNumber)
        let rawNavArea = try? values.decode(String.self, forKey: .navArea)
        
        // Ignore earthquakes with missing data.
        guard let msgYear = rawMsgYear,
              let msgNumber = rawMsgNumber,
              let navArea = rawNavArea
        else {
            let values = "msgYear = \(rawMsgYear?.description ?? "nil"), "
            + "msgNumber = \(rawMsgNumber?.description ?? "nil"), "
            + "navArea = \(rawNavArea?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.msgYear = msgYear
        self.msgNumber = msgNumber
        self.navArea = navArea
        self.cancelMsgNumber = try? values.decode(Int.self, forKey: .cancelMsgNumber)
        self.authority = try? values.decode(String.self, forKey: .authority)
        self.cancelMsgYear = try? values.decode(Int.self, forKey: .cancelMsgYear)
        self.cancelNavArea = try? values.decode(String.self, forKey: .cancelNavArea)
        self.status = try? values.decode(String.self, forKey: .status)
        self.subregion = try? values.decode(String.self, forKey: .subregion)
        self.text = try? values.decode(String.self, forKey: .text)
        
        var parsedCancelDate: Date?
        if let cancelDateString = try? values.decode(String.self, forKey: .cancelDate) {
            if let date = NavigationalWarningModel.apiToDateFormatter.date(from: cancelDateString) {
                parsedCancelDate = date
            }
        }
        self.cancelDate = parsedCancelDate
        
        var parsedDate: Date?
        if let dateString = try? values.decode(String.self, forKey: .issueDate) {
            if let date = NavigationalWarningModel.apiToDateFormatter.date(from: dateString) {
                parsedDate = date
            }
        }
        self.issueDate = parsedDate
        self.locations = nil
    }
    
    // The keys must have the same name as the attributes of the NavigationalWarning entity.
    var dictionaryValue: [String: Any?] {
        [
            "cancelMsgNumber": cancelMsgNumber,
            "authority": authority,
            "cancelDate": cancelDate,
            "cancelMsgYear": cancelMsgYear,
            "cancelNavArea": cancelNavArea,
            "issueDate": issueDate,
            "msgNumber": msgNumber,
            "msgYear": msgYear,
            "navArea": navArea,
            "status": status,
            "subregion": subregion,
            "text": text
        ]
    }

    var sfGeometry: SFGeometry? {
        let collection = SFGeometryCollection()
        if let locations = locations {
            for location in locations {
                if let geometry = locationGeometry(location: location) {
                    collection?.addGeometry(geometry)
                }
            }
        }

        return collection
    }

    func geodesicLine(
        firstPoint: CLLocationCoordinate2D?,
        flipped: inout SFLineString?,
        sfLineString: SFLineString,
        previousPoint: CLLocationCoordinate2D,
        currentPoint: CLLocationCoordinate2D
    ) {
        var coords: [CLLocationCoordinate2D] = [previousPoint, currentPoint]
        let geodesicLine = MKGeodesicPolyline(coordinates: &coords, count: 2)

        let glpoints = geodesicLine.points()

        for glpoint in UnsafeBufferPointer(start: glpoints, count: geodesicLine.pointCount) {
            let currentGlPoint = glpoint.coordinate
            if let firstPoint = firstPoint,
               abs(firstPoint.longitude - currentGlPoint.longitude) > 90 {
                if flipped == nil {
                    flipped = SFLineString()
                }
                flipped?.addPoint(
                    SFPoint(
                        xValue: currentGlPoint.longitude,
                        andYValue: currentGlPoint.latitude
                    )
                )

            } else {
                sfLineString.addPoint(
                    SFPoint(
                        xValue: currentGlPoint.longitude,
                        andYValue: currentGlPoint.latitude
                    )
                )

            }
        }
    }

    func locationPolygon(polygon: MKPolygon) -> SFGeometry? {
        let sfPoly = SFPolygon()
        var previousPoint: CLLocationCoordinate2D?
        var firstPoint: CLLocationCoordinate2D?
        var flipped: SFLineString?

        if let sfLineString = SFLineString() {
            for point in polygon.points().toArray(capacity: polygon.pointCount) {
                if firstPoint == nil {
                    firstPoint = point.coordinate
                }
                if let previous = previousPoint {
                    let currentPoint = point.coordinate
                    geodesicLine(
                        firstPoint: firstPoint,
                        flipped: &flipped,
                        sfLineString: sfLineString,
                        previousPoint: previous,
                        currentPoint: currentPoint
                    )
                    previousPoint = currentPoint
                } else {
                    previousPoint = point.coordinate
                }
            }

            // now draw the geodesic line between the last and the first
            if let previousPoint = previousPoint, let firstPoint = firstPoint {
                geodesicLine(
                    firstPoint: firstPoint,
                    flipped: &flipped,
                    sfLineString: sfLineString,
                    previousPoint: previousPoint,
                    currentPoint: firstPoint
                )
            }

            sfPoly?.addRing(sfLineString)
        }
        if let flipped = flipped, let sfPoly = sfPoly, let flippedPoly = SFPolygon(ring: flipped) {
            return SFGeometryCollection(geometries: [flippedPoly, sfPoly])
        }
        return sfPoly
    }

    func locationLine(polyline: MKPolyline) -> SFGeometry? {
        let sfLineString = SFLineString()

        for point in polyline.points().toArray(capacity: polyline.pointCount) {
            sfLineString?.addPoint(
                SFPoint(
                    xValue: point.coordinate.longitude,
                    andYValue: point.coordinate.latitude
                )
            )
        }
        return sfLineString
    }

    func locationGeometry(location: [String: String]) -> SFGeometry? {
        guard let wkt = location["wkt"] else {
            return nil
        }
        var distance: Double?
        if let distanceString = location["distance"] {
            distance = Double(distanceString)
        }
        if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
            if let polygon = shape as? MKPolygon {
                return locationPolygon(polygon: polygon)
            } else if let polyline = shape as? MKGeodesicPolyline {
                return locationLine(polyline: polyline)
            } else if let polyline = shape as? MKPolyline {
                return locationLine(polyline: polyline)
            } else if let point = shape as? MKPointAnnotation {
                return SFPoint(xValue: point.coordinate.longitude, andYValue: point.coordinate.latitude)
            } else if let circle = shape as? MKCircle {
                return SFPoint(xValue: circle.coordinate.longitude, andYValue: circle.coordinate.latitude)
            }
        }

        return nil
    }

}
// swiftlint:enable type_body_length
