//
//  NewMapLayerViewModelTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/28/23.
//

import XCTest
import OHHTTPStubs

@testable import Marlin

final class NewMapLayerViewModelTests: XCTestCase {

    func testParsing() {
        let url = OHPathForFile("wms.xml", type(of: self))!
        let string = try! String(contentsOfFile: url)
        let model: NewMapLayerViewModel = NewMapLayerViewModel()
        let capabilities = model.parseDocument(string: string)
        
        XCTAssertEqual(capabilities?.title, "GeoServer Web Map Service")
        XCTAssertEqual(capabilities?.abstract, "Web Map Service for map access implementing WMS 1.1.1 and WMS 1.3.0. Dynamic styling provided by the SLD 1.0 extension with partial support for SE 1.1. Additional formats can be generated including PDF, SVG, KML, GeoRSS. Vendor options available for customization including CQL_FILTER.")
        XCTAssertEqual(capabilities?.version, "1.3.0")
        XCTAssertEqual(capabilities?.contactPerson, "Andreas Hocevar")
        XCTAssertEqual(capabilities?.contactOrganization, "ahocevar geospatial")
        XCTAssertEqual(capabilities?.contactTelephone, "+436604376588")
        XCTAssertEqual(capabilities?.contactEmail, "mail@ahocevar.com")
        
        print("xxx layers \(capabilities?.layers)")
    }
}
