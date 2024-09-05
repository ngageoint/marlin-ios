//
//  CLLocationCoordinate2DExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 6/16/22.
//

import Foundation
import MapKit
import gars_ios
import mgrs_ios

struct DMSCoordinate {
    var degrees: Int?
    var minutes: Int?
    var seconds: Int?
    var decimalSeconds: Int?
    var direction: String?
}

extension CLLocationCoordinate2D {
    
    func circleCoordinates(
        radiusMeters: Double,
        startDegrees: Double = 0.0,
        endDegrees: Double = 360.0
    ) -> [CLLocationCoordinate2D] {
        let center = self
        var coordinates: [CLLocationCoordinate2D] = []
        let centerLatRad = center.latitude.toRadians()
        let centerLonRad = center.longitude.toRadians()
        let dRad = radiusMeters / 6378137
        
        let radial = Double(startDegrees).toRadians()
        let latRad = asin(sin(centerLatRad) * cos(dRad) + cos(centerLatRad) * sin(dRad) * cos(radial))
        let dlonRad = atan2(sin(radial) * sin(dRad) * cos(centerLatRad), cos(dRad) - sin(centerLatRad) * sin(latRad))
        let lonRad = fmod((centerLonRad + dlonRad + .pi), 2.0 * .pi) - .pi
        coordinates.append(CLLocationCoordinate2D(latitude: latRad.toDegrees(), longitude: lonRad.toDegrees()))
        
        if startDegrees >= endDegrees {
            // this could be an error in the data, or sometimes lights are defined as follows:
            // characteristic Q.W.R.
            // remarks R. 289°-007°, W.-007°.
            // that would mean this light flashes between red and white over those angles
            // TODO: figure out what to do with multi colored lights over the same sector
            return coordinates
        }
        for i in Int(startDegrees)...Int(endDegrees) {
            let radial = Double(i).toRadians()
            let latRad = asin(sin(centerLatRad) * cos(dRad) + cos(centerLatRad) * sin(dRad) * cos(radial))
            let dlonRad = atan2(
                sin(radial) * sin(dRad) * cos(centerLatRad),
                cos(dRad) - sin(centerLatRad) * sin(latRad)
            )
            let lonRad = fmod((centerLonRad + dlonRad + .pi), 2.0 * .pi) - .pi
            coordinates.append(CLLocationCoordinate2D(latitude: latRad.toDegrees(), longitude: lonRad.toDegrees()))
        }
        
        let endRadial = Double(endDegrees).toRadians()
        let endLatRad = asin(sin(centerLatRad) * cos(dRad) + cos(centerLatRad) * sin(dRad) * cos(endRadial))
        let endDlonRad = atan2(
            sin(endRadial) * sin(dRad) * cos(centerLatRad),
            cos(dRad) - sin(centerLatRad) * sin(endLatRad)
        )
        let endLonRad = fmod((centerLonRad + endDlonRad + .pi), 2.0 * .pi) - .pi
        coordinates.append(CLLocationCoordinate2D(latitude: endLatRad.toDegrees(), longitude: endLonRad.toDegrees()))
        
        return coordinates
    }
    
    func toPixel(
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox,
        tileSize: Double,
        canCross180thMeridian: Bool = true
    ) -> CGPoint {
        var object3857Location = to3857()
        
        // TODO: this logic should be improved
        // just check on the edges of the world presuming that no light will span 90 degrees, which none will
        if canCross180thMeridian && (longitude < -90 || longitude > 90) {
            // if the x location has fallen off the left side and this tile is on the other side of the world
            if object3857Location.x > tileBounds3857.swCorner.x
                && tileBounds3857.swCorner.x < 0
                && object3857Location.x > 0 {
                let newCoordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude - 360.0)
                object3857Location = newCoordinate.to3857()
            }
            
            // if the x value has fallen off the right side and this tile is on the other side of the world
            if object3857Location.x < tileBounds3857.neCorner.x
                && tileBounds3857.neCorner.x > 0
                && object3857Location.x < 0 {
                let newCoordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude + 360.0)
                object3857Location = newCoordinate.to3857()
            }
        }
        
        let xPosition = (
            (
                (object3857Location.x - tileBounds3857.swCorner.x)
                / (tileBounds3857.neCorner.x - tileBounds3857.swCorner.x)
            )
            * tileSize
        )
        let yPosition = tileSize - (
            (
                (object3857Location.y - tileBounds3857.swCorner.y)
                / (tileBounds3857.neCorner.y - tileBounds3857.swCorner.y)
            )
            * tileSize
        )
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    func to3857() -> (x: Double, y: Double) {
        let a = 6378137.0
        let lambda = longitude / 180 * Double.pi
        let phi = latitude / 180 * Double.pi
        let x = a * lambda
        let y = a * log(tan(Double.pi / 4 + phi / 2))
        
        return (x: x, y: y)
    }
    
    static func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    static func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
    
    func bearing(to point: CLLocationCoordinate2D) -> Double {
        let lat1 = CLLocationCoordinate2D.degreesToRadians(latitude)
        let lon1 = CLLocationCoordinate2D.degreesToRadians(longitude)
        
        let lat2 = CLLocationCoordinate2D.degreesToRadians(point.latitude)
        let lon2 = CLLocationCoordinate2D.degreesToRadians(point.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        let degrees = CLLocationCoordinate2D.radiansToDegrees(radiansBearing)
        if degrees > 360 {
            return degrees - 360
        }
        if degrees < 0 {
            return degrees + 360
        }
        
        return degrees
    }
    
    func generalDirection(to point: CLLocationCoordinate2D) -> String {
        let directions = ["N", "NNE", "NE", "ENE",
                          "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW",
                          "W", "WNW", "NW", "NNW"]
        let bearingCorrection = 360.0 / Double(directions.count * 2)
        let indexDegrees = 360.0 / Double(directions.count)

        var bearing = self.bearing(to: point)
        bearing = Double(bearing) + (bearingCorrection)
        if bearing < 0 {
            bearing += 360
        }
        if bearing > 360 {
            bearing -= 360
        }
        let index = Int(Double(bearing / indexDegrees).rounded(.down)) % directions.count
        return directions[index]
    }

    static func validateDirectionAsLastCharacter(
        coordinateToParse: String,
        latitude: Bool
    ) -> Bool {
        if let direction = coordinateToParse.last {
            // the last character must be either N or S not a number
            if direction.wholeNumberValue != nil {
                return false
            } else {
                if latitude && direction.uppercased() != "N" && direction.uppercased() != "S" {
                    return false
                }
                if !latitude && direction.uppercased() != "E" && direction.uppercased() != "W" {
                    return false
                }
            }
        } else {
            return false
        }
        return true
    }

    static func hasValidCharacters(coordinate: String) -> Bool {
        var validCharacters = CharacterSet()
        validCharacters.formUnion(.decimalDigits)
        validCharacters.insert(charactersIn: ".NSEWnsew °\'\"")
        return coordinate.rangeOfCharacter(from: validCharacters.inverted) == nil
    }

    static func removeDMSSymbols(coordinate: String) -> String {
        var charactersToKeep = CharacterSet()
        charactersToKeep.formUnion(.decimalDigits)
        charactersToKeep.insert(charactersIn: ".NSEWnsew")
        return coordinate.components(separatedBy: charactersToKeep.inverted).joined()
    }

    static func hasCorrectNumberOfDigits(coordinate: String, latitude: Bool) -> Bool {
        // there must be either 5 or 6 digits for latitude (1 or 2 degrees, 2 minutes, 2 seconds)
        // or 5, 6, 7 digits for longitude
        if latitude && (coordinate.count < 5 || coordinate.count > 6) {
            return false
        }
        if !latitude && (coordinate.count < 5 || coordinate.count > 7) {
            return false
        }
        return true
    }
    
    init?(coordinateString: String) {
        let initialSplit = coordinateString.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).components(
            separatedBy: CharacterSet(charactersIn: " ,")
        )
        if initialSplit.count == 2,
           let latitude = Double(initialSplit[0]),
           let longitude = Double(initialSplit[1]) {
            self.init(latitude: latitude, longitude: longitude)
            return
        }
        
        if let coordinate = CLLocationCoordinate2D.parse(coordinates: coordinateString) {
            self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return
        }
        
        if initialSplit.count == 1,
            Double(initialSplit[0]) != nil {
            // this is not a valid coordinate, just bail
            return nil
        }
        
        if let latlon = CLLocationCoordinate2D.parseLatitudeLongitudePattern(
            coordinateString: coordinateString
        ) {
            self.init(latitude: latlon[0], longitude: latlon[1])
            return
        }
        return nil
    }
}
