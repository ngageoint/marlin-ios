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

enum CoordinateDisplayType: Int, CustomStringConvertible {
    case latitudeLongitude, degreesMinutesSeconds, mgrs, gars
    
    var description: String {
        switch(self) {
        case .latitudeLongitude:
            return "Latitude, Longitude"
        case .degreesMinutesSeconds:
            return "Degrees, Minutes, Seconds"
        case .mgrs:
            return "Military Grid Reference System"
        case .gars:
            return "Global Area Reference System"
        }
    }
    
    func format(coordinate: CLLocationCoordinate2D) -> String {
        switch UserDefaults.standard.coordinateDisplay {
        case .latitudeLongitude:
            let nf = NumberFormatter()
            nf.maximumFractionDigits = 4
            return "\(nf.string(for: coordinate.latitude) ?? ""), \(nf.string(for: coordinate.longitude) ?? "")"
        case .degreesMinutesSeconds:
            return "\(CLLocationCoordinate2D.latitudeDMSString(coordinate: coordinate.latitude)), \(CLLocationCoordinate2D.longitudeDMSString(coordinate: coordinate.longitude))"
        case .gars:
            return GARS.from(coordinate).coordinate()
        case .mgrs:
            return MGRS.from(coordinate).coordinate()
        }
    }
}

struct DMSCoordinate {
    var degrees: Int?
    var minutes: Int?
    var seconds: Int?
    var direction: String?
}

extension CLLocationCoordinate2D {
    
    func toPixel(zoomLevel: Int, tileBounds3857: MapBoundingBox, tileSize: Double) -> CGPoint {
        var object3857Location = to3857()
        
        // TODO: this logic should be improved
        // just check on the edges of the world presuming that no light will span 90 degrees, which none will
        if longitude < -90 || longitude > 90 {
            // if the x location has fallen off the left side and this tile is on the other side of the world
            if object3857Location.x > tileBounds3857.swCorner.x && tileBounds3857.swCorner.x < 0 && object3857Location.x > 0 {
                let newCoordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude - 360.0)
                object3857Location = newCoordinate.to3857()
            }
            
            // if the x value has fallen off the right side and this tile is on the other side of the world
            if object3857Location.x < tileBounds3857.neCorner.x && tileBounds3857.neCorner.x > 0 && object3857Location.x < 0 {
                let newCoordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude + 360.0)
                object3857Location = newCoordinate.to3857()
            }
        }
        
        let xPosition = (((object3857Location.x - tileBounds3857.swCorner.x) / (tileBounds3857.neCorner.x - tileBounds3857.swCorner.x)) * tileSize)
        let yPosition = tileSize - (((object3857Location.y - tileBounds3857.swCorner.y) / (tileBounds3857.neCorner.y - tileBounds3857.swCorner.y)) * tileSize)
        return CGPoint(x:xPosition, y: yPosition)
    }
    
    func to3857() -> (x: Double, y: Double) {
        let a = 6378137.0
        let lambda = longitude / 180 * Double.pi;
        let phi = latitude / 180 * Double.pi;
        let x = a * lambda;
        let y = a * log(tan(Double.pi / 4 + phi / 2));
        
        return (x:x, y:y);
    }
    
    static func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    static func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
    
    func bearing(to point: CLLocationCoordinate2D) -> Double {
        
        
        let lat1 = CLLocationCoordinate2D.degreesToRadians(latitude)
        let lon1 = CLLocationCoordinate2D.degreesToRadians(longitude)
        
        let lat2 = CLLocationCoordinate2D.degreesToRadians(point.latitude);
        let lon2 = CLLocationCoordinate2D.degreesToRadians(point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        let degrees = CLLocationCoordinate2D.radiansToDegrees(radiansBearing)
        if (degrees > 360) {
            return degrees - 360;
        }
        if (degrees < 0) {
            return degrees + 360;
        }
        
        return degrees;
    }
    
    func generalDirection(to point: CLLocationCoordinate2D) -> String {
        let directions = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW", "NW", "NNW"]
        let bearingCorrection = 360.0 / Double(directions.count * 2)
        let indexDegrees = 360.0 / Double(directions.count)

        var bearing = self.bearing(to: point)
        bearing = Double(bearing) + (bearingCorrection)
        if bearing < 0 {
            bearing = bearing + 360
        }
        if bearing > 360 {
            bearing = bearing - 360
        }
        let index = Int(Double(bearing / indexDegrees).rounded(.down)) % directions.count
        return directions[index]
    }
    
    public func toDisplay() -> String {
        switch UserDefaults.standard.coordinateDisplay {
        case .latitudeLongitude:
            let nf = NumberFormatter()
            nf.maximumFractionDigits = 4
            return "\(nf.string(for: self.latitude) ?? ""), \(nf.string(for: self.longitude) ?? "")"
        case .degreesMinutesSeconds:
            return "\(CLLocationCoordinate2D.latitudeDMSString(coordinate: self.latitude)), \(CLLocationCoordinate2D.longitudeDMSString(coordinate: self.longitude))"
        case .gars:
            return GARS.from(self).coordinate()
        case .mgrs:
            return MGRS.from(self).coordinate()
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
                // if the last direction index is the end of the string use the first index unless the first and last index are the same
                if lastDirectionIndex == firstDirectionIndex {
                    // only one coordinate
                    split.append(coordinatesToParse)
                } else if let firstDirectionIndex = firstDirectionIndex {
                    split.append("\(coordinatesToParse.prefix(upTo: coordinatesToParse.index(firstDirectionIndex, offsetBy: 1)))")
                    split.append("\(coordinatesToParse.suffix(from: coordinatesToParse.index(firstDirectionIndex, offsetBy: 1)))")
                }
            }
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
        // could either be a decimal or a whole number representing lat/lng or a DDMMSS.sss number representing degree minutes seconds
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
        
    // Need to parse the following formats:
    // 1. 112233N 0112244W
    // 2. N 11 ° 22'33 "- W 11 ° 22'33
    // 3. 11 ° 22'33 "N - 11 ° 22'33" W
    // 4. 11° 22'33 N 011° 22'33 W
    static func parseDMS(coordinate: String, addDirection: Bool = false, latitude: Bool = false) -> DMSCoordinate {
        var dmsCoordinate: DMSCoordinate = DMSCoordinate()
        
        var coordinateToParse = coordinate.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if addDirection {
            // check if the first character is negative
            if coordinateToParse.firstIndex(of: "-") == coordinateToParse.startIndex {
                dmsCoordinate.direction = latitude ? "S" : "W"
            } else {
                dmsCoordinate.direction = latitude ? "N" : "E"
            }
        }
        
        var charactersToKeep = CharacterSet()
        charactersToKeep.formUnion(.decimalDigits)
        charactersToKeep.insert(charactersIn: ".NSEWnsew")
        coordinateToParse = coordinate.components(separatedBy: charactersToKeep.inverted).joined()
        
        if let direction = coordinateToParse.last {
            // the last character might be a direction not a number
            if let _ = direction.wholeNumberValue {
                
            } else {
                dmsCoordinate.direction = "\(direction)".uppercased()
                coordinateToParse = "\(coordinateToParse.dropLast(1))"
            }
        }
        if let direction = coordinateToParse.first {
            // the first character might be a direction not a number
            if let _ = direction.wholeNumberValue {
                
            } else {
                dmsCoordinate.direction = "\(direction)".uppercased()
                coordinateToParse = "\(coordinateToParse.dropFirst(1))"
            }
        }
        // remove all characers except numbers and decimal points
        charactersToKeep = CharacterSet()
        charactersToKeep.formUnion(.decimalDigits)
        charactersToKeep.insert(charactersIn: ".")
        coordinateToParse = coordinate.components(separatedBy: charactersToKeep.inverted).joined()
        
        // split the numbers before the decimal seconds
        if coordinateToParse.isEmpty {
            return dmsCoordinate
        }
        let split = coordinateToParse.split(separator: ".")
        
        coordinateToParse = "\(split[0])"
        let decimalSeconds = split.count == 2 ? Int(split[1]) : nil
        
        dmsCoordinate.seconds = Int(coordinateToParse.suffix(2))
        coordinateToParse = "\(coordinateToParse.dropLast(2))"
        
        dmsCoordinate.minutes = Int(coordinateToParse.suffix(2))
        dmsCoordinate.degrees = Int(coordinateToParse.dropLast(2))
        
        if dmsCoordinate.degrees == nil {
            if dmsCoordinate.minutes == nil {
                dmsCoordinate.degrees = dmsCoordinate.seconds
                dmsCoordinate.seconds = nil
            } else {
                dmsCoordinate.degrees = dmsCoordinate.minutes
                dmsCoordinate.minutes = dmsCoordinate.seconds
                dmsCoordinate.seconds = nil
            }
        }
        
        if dmsCoordinate.minutes == nil && dmsCoordinate.seconds == nil && decimalSeconds != nil {
            // this would be the case if a decimal degrees was passed in ie 11.123
            let decimal = Double(".\(decimalSeconds ?? 0)") ?? 0.0
            dmsCoordinate.minutes = Int(abs((decimal.truncatingRemainder(dividingBy: 1) * 60.0)))
            let seconds = abs(((decimal.truncatingRemainder(dividingBy: 1) * 60.0).truncatingRemainder(dividingBy: 1) * 60.0))
            dmsCoordinate.seconds = Int(seconds.rounded())
        } else if let decimalSeconds = decimalSeconds {
            // add the decimal seconds to seconds and round
            dmsCoordinate.seconds = Int(Double("\((dmsCoordinate.seconds ?? 0)).\(decimalSeconds)")?.rounded() ?? 0)
        }
        
        if dmsCoordinate.seconds == 60 {
            dmsCoordinate.minutes = (dmsCoordinate.minutes ?? 0) + 1
            dmsCoordinate.seconds = 0
        }
        
        if dmsCoordinate.minutes == 60 {
            dmsCoordinate.degrees = (dmsCoordinate.degrees ?? 0) + 1
            dmsCoordinate.minutes = 0
        }
        
        return dmsCoordinate
    }
    
    public static func validateLatitudeFromDMS(latitude: String?) -> Bool {
        return validateCoordinateFromDMS(coordinate: latitude, latitude: true)
    }
    
    public static func validateLongitudeFromDMS(longitude: String?) -> Bool {
        return validateCoordinateFromDMS(coordinate: longitude, latitude: false)
    }
    
    public static func validateCoordinateFromDMS(coordinate: String?, latitude: Bool) -> Bool {
        guard let coordinate = coordinate else {
            return false
        }
        
        var validCharacters = CharacterSet()
        validCharacters.formUnion(.decimalDigits)
        validCharacters.insert(charactersIn: ".NSEWnsew °\'\"")
        if coordinate.rangeOfCharacter(from: validCharacters.inverted) != nil {
            return false
        }
        
        var charactersToKeep = CharacterSet()
        charactersToKeep.formUnion(.decimalDigits)
        charactersToKeep.insert(charactersIn: ".NSEWnsew")
        var coordinateToParse = coordinate.components(separatedBy: charactersToKeep.inverted).joined()
        
        // There must be a direction as the last character
        if let direction = coordinateToParse.last {
            // the last character must be either N or S not a number
            if let _ = direction.wholeNumberValue {
                return false
            } else {
                if latitude && direction.uppercased() != "N" && direction.uppercased() != "S" {
                    return false
                }
                if !latitude && direction.uppercased() != "E" && direction.uppercased() != "W" {
                    return false
                }
                coordinateToParse = "\(coordinateToParse.dropLast(1))"
            }
        } else {
            return false
        }
        
        // split the numbers before the decimal seconds
        let split = coordinateToParse.split(separator: ".")
        if split.isEmpty  {
            return false
        }
        
        coordinateToParse = "\(split[0])"
        
        // there must be either 5 or 6 digits for latitude (1 or 2 degrees, 2 minutes, 2 seconds)
        // or 5, 6, 7 digits for longitude
        if latitude && (coordinateToParse.count < 5 || coordinateToParse.count > 6) {
            return false
        }
        if !latitude && (coordinateToParse.count < 5 || coordinateToParse.count > 7) {
            return false
        }
        
        var decimalSeconds = 0
        
        if split.count == 2 {
            if let decimalSecondsInt = Int(split[1]) {
                decimalSeconds = decimalSecondsInt
            } else {
                return false
            }
        }
        
        let seconds = Int(coordinateToParse.suffix(2))
        coordinateToParse = "\(coordinateToParse.dropLast(2))"
        
        let minutes = Int(coordinateToParse.suffix(2))
        let degrees = Int(coordinateToParse.dropLast(2))
        
        if let degrees = degrees {
            if latitude && (degrees < 0 || degrees > 90) {
                return false
            }
            if !latitude && (degrees < 0 || degrees > 180) {
                return false
            }
        } else {
            return false
        }
        
        if let minutes = minutes, let degrees = degrees {
            if (minutes < 0 || minutes > 59) || (latitude && degrees == 90 && minutes != 0) || (!latitude && degrees == 180 && minutes != 0) {
                return false
            }
        } else {
            return false
        }
        
        if let seconds = seconds, let degrees = degrees {
            if (seconds < 0 || seconds > 59) || (latitude && degrees == 90 && (seconds != 0 || decimalSeconds != 0)) || (!latitude && degrees == 180 && (seconds != 0 || decimalSeconds != 0)) {
                return false
            }
        } else {
            return false
        }
        
        return true
    }
    
    // attempts to parse what was passed in to DDD° MM' SS.sss" (NS) or returns "" if unparsable
    public static func parseToDMSString(_ string: String?, addDirection: Bool = false, latitude: Bool = false) -> String? {
        guard let string = string else {
            return nil
        }
        
        if string.isEmpty {
            return ""
        }
        
        let parsed = parseDMS(coordinate: string, addDirection: addDirection, latitude: latitude)
        
        let direction = parsed.direction ?? ""
        
        var seconds = ""
        if let parsedSeconds = parsed.seconds {
            seconds = String(format: "%02d", parsedSeconds)
        }
        
        var minutes = ""
        if let parsedMinutes = parsed.minutes {
            minutes = String(format: "%02d", parsedMinutes)
        }
        
        var degrees = ""
        if let parsedDegrees = parsed.degrees {
            degrees = "\(parsedDegrees)"
        }
        
        if !degrees.isEmpty {
            degrees = "\(degrees)° "
        }
        if !minutes.isEmpty {
            minutes = "\(minutes)\' "
        }
        if !seconds.isEmpty {
            seconds = "\(seconds)\" "
        }
        
        return "\(degrees)\(minutes)\(seconds)\(direction)"
    }
    
    public static func latitudeDMSString(coordinate: CLLocationDegrees) -> String {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        nf.minimumIntegerDigits = 2
        
        var latDegrees: Int = Int(coordinate)
        var latMinutes = Int(abs((coordinate.truncatingRemainder(dividingBy: 1) * 60.0)))
        var latSeconds = abs(((coordinate.truncatingRemainder(dividingBy: 1) * 60.0).truncatingRemainder(dividingBy: 1) * 60.0)).rounded()
        if latSeconds == 60 {
            latSeconds = 0
            latMinutes += 1
        }
        if latMinutes == 60 {
            latDegrees += 1
            latMinutes = 0
        }
        return "\(abs(latDegrees))° \(nf.string(for: latMinutes) ?? "")\' \(nf.string(for: latSeconds) ?? "")\" \(latDegrees >= 0 ? "N" : "S")"
    }
    
    public static func longitudeDMSString(coordinate: CLLocationDegrees) -> String {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        nf.minimumIntegerDigits = 2
        
        var lonDegrees: Int = Int(coordinate)
        var lonMinutes = Int(abs((coordinate.truncatingRemainder(dividingBy: 1) * 60.0)))
        var lonSeconds = abs(((coordinate.truncatingRemainder(dividingBy: 1) * 60.0).truncatingRemainder(dividingBy: 1) * 60.0)).rounded()
        if lonSeconds == 60 {
            lonSeconds = 0
            lonMinutes += 1
        }
        if lonMinutes == 60 {
            lonDegrees += 1
            lonMinutes = 0
        }
        return "\(abs(lonDegrees))° \(nf.string(for: lonMinutes) ?? "")\' \(nf.string(for: lonSeconds) ?? "")\" \(lonDegrees >= 0 ? "E" : "W")"
    }

    init?(coordinateString: String) {
        let initialSplit = coordinateString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: CharacterSet(charactersIn: " ,"))
        if initialSplit.count == 2, let latitude = Double(initialSplit[0]), let longitude = Double(initialSplit[1]) {
            self.init(latitude: latitude, longitude: longitude)
            return
        }
        
        if let coordinate = CLLocationCoordinate2D.parse(coordinates: coordinateString) {
            self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return
        }
        
        if initialSplit.count == 1, let _ = Double(initialSplit[0]) {
            // this is not a valid coordinate, just bail
            return nil
        }
        
        let p = #"(?<latdeg>-?[0-9]*\.?\d+)[\s°-]*(?<latminutes>\d{1,2}\.?\d+)?[\s\`'-]*(?<latseconds>\d{1,2}\.?\d+)?[\s\" ]?(?<latdirection>([NOEWS])?)[\s,]*(?<londeg>-?[0-9]*\.?\d+)[\s°-]*(?<lonminutes>\d{1,2}\.?\d+)?[\s\`'-]*(?<lonseconds>\d{1,2}\.?\d+)?[\s\" ]*(?<londirection>([NOEWS])?)"#
        
        var foundLat: Bool = false
        var foundLon: Bool = false
        var latlon = [Double]()
        do {
            let regex = try NSRegularExpression(pattern: p)
            let matches = regex.matches(in: coordinateString, range: NSRange(coordinateString.startIndex..., in: coordinateString))
            var latdegrees: Double = 0.0
            var latmultiplier: Double = 1.0
            var londegrees: Double = 0.0
            var lonmultiplier: Double = 1.0

            for match in matches {
                for component in ["latdirection", "latdeg", "latminutes", "latseconds", "londirection", "londeg", "lonminutes", "lonseconds"] {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound,
                       let range = Range(nsrange, in: coordinateString),
                       !range.isEmpty
                    {
                        if component == "latdirection" {
                            latmultiplier = "NEO".contains(coordinateString[range]) ? 1.0 : -1.0
                        } else if component == "latdeg" {
                            foundLat = true
                            latdegrees += Double(coordinateString[range]) ?? 0.0
                        } else if component == "latminutes" {
                            latdegrees += (Double(coordinateString[range]) ?? 0.0) / 60
                        } else if component == "latseconds" {
                            latdegrees += (Double(coordinateString[range]) ?? 0.0) / 3600
                        } else if component == "londirection" {
                            lonmultiplier = "NEO".contains(coordinateString[range]) ? 1.0 : -1.0
                        } else if component == "londeg" {
                            foundLon = true
                            londegrees += Double(coordinateString[range]) ?? 0.0
                        } else if component == "lonminutes" {
                            londegrees += (Double(coordinateString[range]) ?? 0.0) / 60
                        } else if component == "lonseconds" {
                            londegrees += (Double(coordinateString[range]) ?? 0.0) / 3600
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
        self.init(latitude: latlon[0], longitude: latlon[1])
    }
}

extension Double {
    
    init?(coordinateString: String) {
        let p = #"(?<deg>-?[0-9]*\.?\d+)[\s°-]*(?<minutes>\d{1,2}\.?\d+)?[\s\`'-]*(?<seconds>\d{1,2}\.?\d+)?[\s\" ]?(?<direction>([NOEWS])?)"#
        
        var found: Bool = false
        var degrees: Double = 0.0
        var multiplier: Double = 1.0

        do {
            let regex = try NSRegularExpression(pattern: p)
            let matches = regex.matches(in: coordinateString, range: NSRange(coordinateString.startIndex..., in: coordinateString))
            
            for match in matches {
                for component in ["direction", "deg", "minutes", "seconds"] {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound,
                       let range = Range(nsrange, in: coordinateString),
                       !range.isEmpty
                    {
                        if component == "direction" {
                            multiplier = "NEO".contains(coordinateString[range]) ? 1.0 : -1.0
                        } else if component == "deg" {
                            found = true
                            degrees += Double(coordinateString[range]) ?? 0.0
                        } else if component == "minutes" {
                            degrees += (Double(coordinateString[range]) ?? 0.0) / 60
                        } else if component == "seconds" {
                            degrees += (Double(coordinateString[range]) ?? 0.0) / 3600
                        }
                    }
                }
                
                if !found {
                    return nil
                }
            }
        } catch {
            print(error)
            return nil
        }
        if !found {
            return nil
        }
        self.init(floatLiteral: multiplier * degrees)
    }
}
