//
//  CLLocationCoordinate2D+DMSParsing.swift
//  Marlin
//
//  Created by Daniel Barela on 2/29/24.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    // attempts to parse what was passed in to DDD° MM' SS.sss" (NS) or returns "" if unparsable
    public static func parseToDMSString(
        _ string: String?,
        addDirection: Bool = false,
        latitude: Bool = false
    ) -> String? {
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
            let roundedSeconds = Int(Double("\(parsedSeconds).\(parsed.decimalSeconds ?? 0)")?.rounded() ?? 0)
            seconds = String(format: "%02d", roundedSeconds)
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
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 2

        var latDegrees: Int = Int(coordinate)
        var latMinutes = Int(abs((coordinate.truncatingRemainder(dividingBy: 1) * 60.0)))
        var latSeconds = abs(
            (
                (coordinate.truncatingRemainder(dividingBy: 1) * 60.0)
                    .truncatingRemainder(dividingBy: 1) * 60.0
            )).rounded()
        if latSeconds == 60 {
            latSeconds = 0
            latMinutes += 1
        }
        if latMinutes == 60 {
            latDegrees += 1
            latMinutes = 0
        }
        return """
        \(abs(latDegrees))° \(formatter.string(for: latMinutes) ?? "")\' \
        \(formatter.string(for: latSeconds) ?? "")\" \(latDegrees >= 0 ? "N" : "S")
        """
    }

    public static func longitudeDMSString(coordinate: CLLocationDegrees) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 2

        var lonDegrees: Int = Int(coordinate)
        var lonMinutes = Int(abs((coordinate.truncatingRemainder(dividingBy: 1) * 60.0)))
        var lonSeconds = abs(
            (
                (coordinate.truncatingRemainder(dividingBy: 1) * 60.0)
                    .truncatingRemainder(dividingBy: 1) * 60.0
            )).rounded()
        if lonSeconds == 60 {
            lonSeconds = 0
            lonMinutes += 1
        }
        if lonMinutes == 60 {
            lonDegrees += 1
            lonMinutes = 0
        }
        return """
        \(abs(lonDegrees))° \(formatter.string(for: lonMinutes) ?? "")\' \
        \(formatter.string(for: lonSeconds) ?? "")\" \(lonDegrees >= 0 ? "E" : "W")
        """
    }
    
    // Need to parse the following formats:
    // 1. 112233N 0112244W
    // 2. N 11 ° 22'33 "- W 11 ° 22'33
    // 3. 11 ° 22'33 "N - 11 ° 22'33" W
    // 4. 11° 22'33 N 011° 22'33 W
    static func parseDMS(
        coordinate: String,
        addDirection: Bool = false,
        latitude: Bool = false
    ) -> DMSCoordinate {
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
            if direction.wholeNumberValue == nil {
                dmsCoordinate.direction = "\(direction)".uppercased()
                coordinateToParse = "\(coordinateToParse.dropLast(1))"
            }
        }
        if let direction = coordinateToParse.first {
            // the first character might be a direction not a number
            if direction.wholeNumberValue == nil {
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
        print("dms \(dmsCoordinate)")

        CLLocationCoordinate2D.correctMinutesAndSeconds(dmsCoordinate: &dmsCoordinate, decimalSeconds: decimalSeconds)

        return dmsCoordinate
    }

    static func correctMinutesAndSeconds(dmsCoordinate: inout DMSCoordinate, decimalSeconds: Int?) {
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
            let seconds = abs(
                (
                    (decimal.truncatingRemainder(dividingBy: 1) * 60.0)
                        .truncatingRemainder(dividingBy: 1)
                    * 60.0)
            )
            dmsCoordinate.seconds = Int(seconds.rounded())
        } else if let decimalSeconds = decimalSeconds {
            dmsCoordinate.decimalSeconds = decimalSeconds
            // add the decimal seconds to seconds and round
//            dmsCoordinate.seconds = Int(Double("\((dmsCoordinate.seconds ?? 0)).\(decimalSeconds)")?.rounded() ?? 0)
        }

        if dmsCoordinate.seconds == 60 {
            dmsCoordinate.minutes = (dmsCoordinate.minutes ?? 0) + 1
            dmsCoordinate.seconds = 0
        }

        if dmsCoordinate.minutes == 60 {
            dmsCoordinate.degrees = (dmsCoordinate.degrees ?? 0) + 1
            dmsCoordinate.minutes = 0
        }
    }
}
