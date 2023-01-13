//
//  FilterBottomSheetTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/13/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class FilterBottomSheetTests: XCTestCase {
    
    func testFilterBottomSheet() {
        
        UserDefaults.standard.set(0, forKey: "\(Asam.key)Order")
        UserDefaults.standard.set(1, forKey: "\(Light.key)Order")
        UserDefaults.standard.set(2, forKey: "\(Modu.key)Order")
        
        struct Container: View {
            @State var dataSources: [DataSourceItem] = [
                DataSourceItem(dataSource: Asam.self),
                DataSourceItem(dataSource: Modu.self),
                DataSourceItem(dataSource: Light.self)
            ]
            
            var body: some View {
                FilterBottomSheet(dataSources: $dataSources)
            }
        }
        
        let view = Container()

        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "\(Asam.fullDataSourceName) filter row")
        tester().waitForView(withAccessibilityLabel: "\(Modu.fullDataSourceName) filter row")
        tester().waitForView(withAccessibilityLabel: "\(Light.fullDataSourceName) filter row")
    }
}
