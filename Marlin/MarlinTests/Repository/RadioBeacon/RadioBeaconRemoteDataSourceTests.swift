//
//  RadioBeaconRemoteDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import OHHTTPStubs
import Combine

@testable import Marlin

final class RadioBeaconRemoteDataSourceTests: XCTestCase {

    override class func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }

    func testFetchRadioBeaconsWithoutTask() async {
        let dataSource = RadioBeaconRemoteDataSource()

        stub(condition: isScheme("https") && pathEndsWith("/publications/ngalol/radiobeacons")) { request in
            let jsonObject = [
                "ngalol": [
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Radiobeacons",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": 10,
                        "name": "Ittoqqortoormit, Scoresbysund",
                        "position": "70°29'11.99\"N \n21°58'20\"W",
                        "characteristic": "SC\n(• • •  - • - • ).\n",
                        "range": "200",
                        "sequenceText": nil,
                        "frequency": "343\nNON, A2A.",
                        "stationRemark": "Aeromarine.",
                        "postNote": nil,
                        "noticeNumber": 199706,
                        "removeFromList": "N",
                        "deleteFlag": "N",
                        "noticeWeek": "06",
                        "noticeYear": "1997"
                    ],
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Radiobeacons",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": 20,
                        "name": "Kulusuk",
                        "position": "65°31'59.99\"N \n37°10'00\"W",
                        "characteristic": "KK\n(- • -   - • - ).\n",
                        "range": "50",
                        "sequenceText": nil,
                        "frequency": "283\nNON, A2A.",
                        "stationRemark": "Aeromarine.",
                        "postNote": nil,
                        "noticeNumber": 199706,
                        "removeFromList": "N",
                        "deleteFlag": "N",
                        "noticeWeek": "06",
                        "noticeYear": "1997"
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        let beacons = await dataSource.fetch()

        XCTAssertEqual(beacons.count, 2)
        let newBeacon = beacons[0]

        XCTAssertEqual(newBeacon.featureNumber, 10)
        XCTAssertEqual(newBeacon.volumeNumber, "PUB 110")
    }
}
