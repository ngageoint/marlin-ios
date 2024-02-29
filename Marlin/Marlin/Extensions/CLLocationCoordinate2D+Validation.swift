//
//  CLLocationCoordinate2D+Validation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/29/24.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {

    public static func validateLatitudeFromDMS(latitude: String?) -> Bool {
        return validateCoordinateFromDMS(coordinate: latitude, latitude: true)
    }

    public static func validateLongitudeFromDMS(longitude: String?) -> Bool {
        return validateCoordinateFromDMS(coordinate: longitude, latitude: false)
    }
    
    static func degreesAndMinutesSecondsValid(
        degrees: Int?,
        minutes: Int?,
        seconds: Int?,
        decimalSeconds: Int?,
        latitude: Bool
    ) -> Bool {
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
            if (minutes < 0 || minutes > 59)
                || (latitude && degrees == 90 && minutes != 0)
                || (!latitude && degrees == 180 && minutes != 0) {
                return false
            }
        } else {
            return false
        }
        if let seconds = seconds, let degrees = degrees {
            if (seconds < 0 || seconds > 59)
                || (
                    latitude && degrees == 90
                    && (seconds != 0 || decimalSeconds != 0)
                ) || (
                    !latitude && degrees == 180
                    && (seconds != 0 || decimalSeconds != 0)
                ) {
                return false
            }
        } else {
            return false
        }
        return true
    }

    public static func validateCoordinateFromDMS(coordinate: String?, latitude: Bool) -> Bool {
        guard let coordinate = coordinate, hasValidCharacters(coordinate: coordinate) else {
            return false
        }
        var coordinateToParse = removeDMSSymbols(coordinate: coordinate)

        // There must be a direction as the last character
        if !validateDirectionAsLastCharacter(coordinateToParse: coordinateToParse, latitude: latitude) {
            return false
        }

        coordinateToParse = "\(coordinateToParse.dropLast(1))"

        // split the numbers before the decimal seconds
        let split = coordinateToParse.split(separator: ".")
        if split.isEmpty {
            return false
        }

        coordinateToParse = "\(split[0])"

        if !hasCorrectNumberOfDigits(coordinate: coordinateToParse, latitude: latitude) {
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

        if !degreesAndMinutesSecondsValid(
            degrees: degrees,
            minutes: minutes,
            seconds: seconds,
            decimalSeconds: decimalSeconds,
            latitude: latitude
        ) {
            return false
        }

        return true
    }
}
