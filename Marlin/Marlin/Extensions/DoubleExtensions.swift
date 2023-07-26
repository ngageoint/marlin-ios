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

extension UnsafeMutablePointer {
    func toArray(capacity: Int) -> [Pointee] {
        return Array(UnsafeBufferPointer(start: self, count: capacity))
    }
}
