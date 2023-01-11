//
//  ChartCorrectionQueryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/10/23.
//

import XCTest
import SwiftUI

@testable import Marlin

final class ChartCorrectionQueryTests: XCTestCase {
    
    func testRequiredParametersNotSet() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int), comparison: .greaterThanEqual, valueInt: 202052)])
        
        let queryView = ChartCorrectionQuery()
        
        let controller = UIHostingController(rootView: queryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Add Required Filter Parameters")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Query")
    }
    
    func testRequiredParametersSet() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        
        let queryView = ChartCorrectionQuery()
        
        let controller = UIHostingController(rootView: queryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Add Additional Filter Parameters")
        tester().waitForView(withAccessibilityLabel: "Query")
    }
    
    func testRequiredParametersNotSetAndThenSet() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int), comparison: .greaterThanEqual, valueInt: 202052)])
        
        let queryView = ChartCorrectionQuery()
        
        let controller = UIHostingController(rootView: queryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Add Required Filter Parameters")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Query")
        tester().wait(forTimeInterval: 1.0)

        queryView.filterViewModel.filters = [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)]
        tester().wait(forTimeInterval: 1.0)
        
        tester().waitForView(withAccessibilityLabel: "Query")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Add Required Filter Parameters")
    }
}
