//
//  CLLocationCoordinate2D+Parsing.swift
//  Marlin
//
//  Created by Daniel Barela on 2/29/24.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {

    static func splitOnDirection(
        split: inout [String],
        coordinatesToParse: String,
        firstDirectionIndex: String.Index?
    ) {
        let lastDirectionIndex = coordinatesToParse.lastIndex { character in
            let uppercase = character.uppercased()
            return uppercase == "N" || uppercase == "S" || uppercase == "E" || uppercase == "W"
        }
        // the direction will either be at the begining of the string, or the end
        // if the direction is at the begining of the string, use the second index unless there is no second index
        // in which case there is only one coordinate
        if firstDirectionIndex == coordinatesToParse.startIndex {
            if let lastDirectionIndex = lastDirectionIndex, lastDirectionIndex != firstDirectionIndex {
                split.append("\(coordinatesToParse.prefix(upTo: lastDirectionIndex))")
                split.append("\(coordinatesToParse.suffix(from: lastDirectionIndex))")
            } else {
                // only one coordinate
                split.append(coordinatesToParse)
            }
        } else if lastDirectionIndex == coordinatesToParse.index(coordinatesToParse.endIndex, offsetBy: -1) {
            // if the last direction index is the end of the string use the first index
            // unless the first and last index are the same
            if lastDirectionIndex == firstDirectionIndex {
                // only one coordinate
                split.append(coordinatesToParse)
            } else if let firstDirectionIndex = firstDirectionIndex {
                let beforeDirection = coordinatesToParse.prefix(
                    upTo: coordinatesToParse.index(
                        firstDirectionIndex, offsetBy: 1)
                )
                let afterDirection = coordinatesToParse.suffix(
                    from: coordinatesToParse.index(
                        firstDirectionIndex, offsetBy: 1)
                )
                split.append("\(beforeDirection)")
                split.append("\(afterDirection)")
            }
        }
    }

    // splits the string into possibly two coordinates with all spaces removed
    // no further normalization takes place
    static func splitCoordinates(coordinates: String?) -> [String] {
        var split: [String] = []

        guard let coordinates = coordinates else {
            return split
        }

        // trim whitespace from the start and end of the string
        let coordinatesToParse = coordinates.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        // if there is a comma, split on that
        if coordinatesToParse.firstIndex(of: ",") != nil {
            return coordinatesToParse.split(separator: ",").map { splitString in
                return "\(splitString)".components(separatedBy: .whitespacesAndNewlines).joined()
            }
        }

        // check if there are any direction letters
        let firstDirectionIndex = coordinatesToParse.firstIndex { character in
            let uppercase = character.uppercased()
            return uppercase == "N" || uppercase == "S" || uppercase == "E" || uppercase == "W"
        }
        let hasDirection = firstDirectionIndex != nil

        // if the string has a direction we can try to split on the dash
        if hasDirection && coordinatesToParse.firstIndex(of: "-") != nil {
            return coordinatesToParse.split(separator: "-").map { splitString in
                return "\(splitString)".components(separatedBy: .whitespacesAndNewlines).joined()
            }
        } else if hasDirection {
            // if the string has a direction but no dash, split on the direction
            CLLocationCoordinate2D.splitOnDirection(
                split: &split,
                coordinatesToParse: coordinatesToParse,
                firstDirectionIndex: firstDirectionIndex
            )
        }

        // one last attempt to split.  if there is one white space character split on that
        let whitespaceSplit = coordinatesToParse.components(separatedBy: .whitespacesAndNewlines)
        if whitespaceSplit.count <= 2 {
            split = whitespaceSplit
        }

        return split.map { splitString in
            return splitString.components(separatedBy: .whitespacesAndNewlines).joined()
        }
    }

    // best effort parse of the string passed in
    // returns kCLLocationCoordinate2DInvalid if there is no way to parse
    // If only one of latitude or longitude can be parsed, the returned coordinate will have that value set
    // with the other value being CLLocationDegrees.nan.  longitude will be the default returned value
    static func parse(coordinates: String?) -> CLLocationCoordinate2D? {
        var latitude: CLLocationDegrees?
        var longitude: CLLocationDegrees?

        let split = CLLocationCoordinate2D.splitCoordinates(coordinates: coordinates)
        if split.count == 2 {
            latitude = CLLocationCoordinate2D.parse(coordinate: split[0], enforceLatitude: true)
            longitude = CLLocationCoordinate2D.parse(coordinate: split[1], enforceLatitude: false)
        }
        if let latitude = latitude, let longitude = longitude {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }

    // takes one coordinate and translates it into a CLLocationDegrees
    // returns nil if nothing can be parsed
    static func parse(coordinate: String?, enforceLatitude: Bool = false) -> CLLocationDegrees? {
        guard let coordinate = coordinate else {
            return nil
        }

        let normalized = coordinate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // check if it is a number and that number could be a valid latitude or longitude
        // could either be a decimal or a whole number representing lat/lng or a DDMMSS.sss
        // number representing degree minutes seconds
        if let decimalDegrees = Double(normalized) {
            // if either of these are true, parse it as a regular latitude longitude
            if (!enforceLatitude && decimalDegrees >= -180 && decimalDegrees <= 180)
                || (enforceLatitude && decimalDegrees >= -90 && decimalDegrees <= 90) {
                return CLLocationDegrees(decimalDegrees)
            }
        }

        // try to just parse it as DMS
        let dms = CLLocationCoordinate2D.parseDMS(coordinate: normalized)
        if let degrees = dms.degrees {
            var coordinateDegrees = Double(degrees)
            if let minutes = dms.minutes {
                coordinateDegrees += Double(minutes) / 60.0
            }
            if let seconds = dms.seconds {
                coordinateDegrees += Double(seconds) / 3600.0
            }
            if let direction = dms.direction {
                if direction == "S" || direction == "W" {
                    coordinateDegrees = -coordinateDegrees
                }
            }
            return CLLocationDegrees(coordinateDegrees)
        }

        return nil
    }
    
    // Splitting this function would make it less readable
    // swiftlint:disable function_body_length
    static func parseLatitudeLongitudePattern(coordinateString: String) -> [Double]? {
        // swiftlint:disable line_length
        let pattern = #"(?<latdeg>-?[0-9]*\.?\d+)[\s°-]*(?<latminutes>\d{1,2}\.?\d+)?[\s\`'-]*(?<latseconds>\d{1,2}\.?\d+)?[\s\" ]?(?<latdirection>([NOEWS])?)[\s,]*(?<londeg>-?[0-9]*\.?\d+)[\s°-]*(?<lonminutes>\d{1,2}\.?\d+)?[\s\`'-]*(?<lonseconds>\d{1,2}\.?\d+)?[\s\" ]*(?<londirection>([NOEWS])?)"#
        // swiftlint:enable line_length

        var foundLat: Bool = false
        var foundLon: Bool = false
        var latlon = [Double]()
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let matches = regex.matches(
                in: coordinateString,
                range: NSRange(
                    coordinateString.startIndex...,
                    in: coordinateString)
            )
            var latdegrees: Double = 0.0
            var latmultiplier: Double = 1.0
            var londegrees: Double = 0.0
            var lonmultiplier: Double = 1.0

            for match in matches {
                for component in [
                    "latdirection",
                    "latdeg",
                    "latminutes",
                    "latseconds",
                    "londirection",
                    "londeg",
                    "lonminutes",
                    "lonseconds"] {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound,
                       let range = Range(nsrange, in: coordinateString),
                       !range.isEmpty {
                        switch component {
                        case "latdirection":
                            latmultiplier = "NEO".contains(coordinateString[range]) ? 1.0 : -1.0
                        case "latdeg":
                            foundLat = true
                            latdegrees += Double(coordinateString[range]) ?? 0.0
                        case "latminutes":
                            latdegrees += (Double(coordinateString[range]) ?? 0.0) / 60
                        case "latseconds":
                            latdegrees += (Double(coordinateString[range]) ?? 0.0) / 3600
                        case "londirection":
                            lonmultiplier = "NEO".contains(coordinateString[range]) ? 1.0 : -1.0
                        case "londeg":
                            foundLon = true
                            londegrees += Double(coordinateString[range]) ?? 0.0
                        case "lonminutes":
                            londegrees += (Double(coordinateString[range]) ?? 0.0) / 60
                        case "lonseconds":
                            londegrees += (Double(coordinateString[range]) ?? 0.0) / 3600
                        default:
                            break
                        }
                    }
                }

                if !foundLat || !foundLon {
                    return nil
                }
                latlon.append(latmultiplier * latdegrees)
                latlon.append(lonmultiplier * londegrees)
            }
        } catch {
            print(error)
            return nil
        }
        if !foundLat || !foundLon {
            return nil
        }
        return latlon
    }
    // swiftlint:enable function_body_length
}
