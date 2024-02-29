//
//  DoubleExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 4/6/23.
//

import Foundation

extension Double {
    var latitudeDisplay: String {
        return "\(String(format: "%.2f", abs(self)))° \(self < 0 ? "S" : "N")"
    }
    
    var longitudeDisplay: String {
        return "\(String(format: "%.2f", abs(self)))° \(self < 0 ? "W" : "E")"
    }
    
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}

extension Double {

    init?(coordinateString: String) {
        // swiftlint:disable line_length
        let pattern = #"(?<deg>-?[0-9]*\.?\d+)[\s°-]*(?<minutes>\d{1,2}\.?\d+)?[\s\`'-]*(?<seconds>\d{1,2}\.?\d+)?[\s\" ]?(?<direction>([NOEWS])?)"#
        // swiftlint:enable line_length

        var found: Bool = false
        var degrees: Double = 0.0
        var multiplier: Double = 1.0

        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let matches = regex.matches(
                in: coordinateString,
                range: NSRange(
                    coordinateString.startIndex...,
                    in: coordinateString)
            )

            for match in matches {
                for component in ["direction", "deg", "minutes", "seconds"] {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound,
                       let range = Range(nsrange, in: coordinateString),
                       !range.isEmpty {
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

extension UnsafeMutablePointer {
    func toArray(capacity: Int) -> [Pointee] {
        return Array(UnsafeBufferPointer(start: self, count: capacity))
    }
}
