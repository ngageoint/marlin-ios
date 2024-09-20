//
//  ModuRemoteDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import OHHTTPStubs
import Combine

@testable import Marlin

final class ModuRemoteDataSourceTests: XCTestCase {

    override class func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }

    func testFetchModusWithoutTask() async {
        let dataSource = ModuRemoteDataSourceImpl()

        stub(condition: isScheme("https") && pathEndsWith("/publications/modu")) { request in
            let jsonObject = [
                "modu": [
                    [
                        "name": "ABAN II",
                        "date": "2022-09-16",
                        "rigStatus": "Active",
                        "specialStatus": "Wide Berth Requested",
                        "distance": nil,
                        "latitude": 16.34183333300001,
                        "longitude": 81.92416666700001,
                        "position": "16°20'30.6\"N \n81°55'27\"E",
                        "navArea": "HYDROPAC",
                        "region": 6,
                        "subregion": 63
                    ],
                    [
                        "name": "ABAN III",
                        "date": "2022-10-28",
                        "rigStatus": "Inactive",
                        "specialStatus": "Wide Berth Requested",
                        "distance": nil,
                        "latitude": 18.67283333300003,
                        "longitude": 72.35783333299997,
                        "position": "18°40'22.2\"N \n72°21'28.2\"E",
                        "navArea": "HYDROPAC",
                        "region": 6,
                        "subregion": 63
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        let modus = await dataSource.fetch()

        XCTAssertEqual(modus.count, 2)
        let new = modus[0]

        XCTAssertEqual(new.name, "ABAN II")
    }
}
