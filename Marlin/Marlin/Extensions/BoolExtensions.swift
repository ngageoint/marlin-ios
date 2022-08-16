//
//  BoolExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 8/16/22.
//

import Foundation

extension Bool {
    static var iOS16Plus: Bool {
        guard #available(iOS 16, *) else {
            // It's iOS 15 so return true.
            return false
        }
        // It's iOS 16 so return false.
        return true
    }
}
