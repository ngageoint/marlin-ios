//
//  MarlinTestInitialization.swift
//  MarlinTests
//
//  Created by Daniel Barela on 5/30/23.
//

import Foundation

@testable import Marlin

class MarlinTestInitialization: NSObject {
    public override init() {
        print("xxx initialize the tests")
        let mockCLLocation = MockCLLocationManager()
        LocationManager.shared(locationManager: mockCLLocation)
    }
}
