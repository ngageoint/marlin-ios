//
//  NewMapLayerViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/28/23.
//

import XCTest
import OHHTTPStubs
import SwiftUI

@testable import Marlin

final class NewMapLayerViewTests: XCTestCase {

    func testLoading() throws {
        
        stub(condition: isScheme("https") && pathEndsWith("wms")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("wms.xml", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/xml"]
            )
        }
        
        let view = MapLayerView(isPresented: Binding.constant(true))
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Layer URL input")
        tester().enterText("https://example.com/wms", intoViewWithAccessibilityLabel: "Layer URL input")
        
        tester().wait(forTimeInterval: 6)
    }

}
