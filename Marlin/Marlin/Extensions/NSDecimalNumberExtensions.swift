//
//  NSDecimalNumberExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 4/4/23.
//

import Foundation

extension NSDecimalNumber {
    var latitudeDisplay: String {
        return "\(String(format: "%.2f", abs(self.doubleValue)))°\(self.doubleValue < 0 ? "S" : "N")"
    }
    
    var longitudeDisplay: String {
        return "\(String(format: "%.2f", abs(self.doubleValue)))°\(self.doubleValue < 0 ? "W" : "E")"
    }
}
