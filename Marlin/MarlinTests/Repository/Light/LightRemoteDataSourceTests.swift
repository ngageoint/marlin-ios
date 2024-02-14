//
//  LightRemoteDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import OHHTTPStubs
import Combine

@testable import Marlin

final class LightRemoteDataSourceTests: XCTestCase {

    override class func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }

    func testFetchLightsWithoutTaskNoNoticeNumber() async {
        let dataSource = LightRemoteDataSource()

        stub(condition: isScheme("https") && pathEndsWith("/publications/ngalol/lights-buoys") && !containsQueryParams(["volume": "110"])) { request in
            let jsonObject = [
                "ngalol": [
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        stub(condition: isScheme("https") 
             && pathEndsWith("/publications/ngalol/lights-buoys")
             && containsQueryParams([
                "volume": "PUB 110"
             ])
        ) { request in
            let jsonObject = [
                "ngalol": [
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Lighted Aids",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": "ANGMAGSSALIK:",
                        "subregionHeading": nil,
                        "localHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": "4\nL5000",
                        "name": "-Outer.",
                        "position": "65°33'53.89\"N \n37°12'25.7\"W",
                        "charNo": 1,
                        "characteristic": "Fl.W.\nperiod 5s \nfl. 1.0s, ec. 4.0s \n",
                        "heightFeetMeters": "36\n11",
                        "range": "7",
                        "structure": "Yellow pedestal, red band; 7.\n",
                        "remarks": nil,
                        "postNote": nil,
                        "noticeNumber": 201507,
                        "removeFromList": "N",
                        "deleteFlag": "Y",
                        "noticeWeek": "07",
                        "noticeYear": "2015"
                    ],
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Lighted Aids",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": nil,
                        "subregionHeading": nil,
                        "localHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": "6",
                        "name": "Kulusuk, NW Coast, RACON.",
                        "position": "65°33'53.89\"N \n37°12'25.7\"W",
                        "charNo": 1,
                        "characteristic": "T(- )\nperiod 60s \n",
                        "heightFeetMeters": nil,
                        "range": nil,
                        "structure": nil,
                        "remarks": "(3 & 10cm).\n",
                        "postNote": nil,
                        "noticeNumber": 201507,
                        "removeFromList": "N",
                        "deleteFlag": "Y",
                        "noticeWeek": "07",
                        "noticeYear": "2015"
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        let lights = await dataSource.fetch(task: nil, volume: "PUB 110", noticeYear: nil, noticeWeek: nil)

        XCTAssertEqual(lights.count, 2)
    }

    func testFetchLightsWithoutTaskWithNoticeNumber() async {
        let dataSource = LightRemoteDataSource()

        stub(condition: isScheme("https") && pathEndsWith("/publications/ngalol/lights-buoys") && !containsQueryParams(["volume": "110"])) { request in
            let jsonObject = [
                "ngalol": [
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        stub(condition: isScheme("https") && 
             pathEndsWith("/publications/ngalol/lights-buoys") &&
             containsQueryParams([
                "volume": "PUB 110",
                "minNoticeNumber":"201508"
             ])
        ) { request in
            let jsonObject = [
                "ngalol": [
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Lighted Aids",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": "ANGMAGSSALIK:",
                        "subregionHeading": nil,
                        "localHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": "4\nL5000",
                        "name": "-Outer.",
                        "position": "65°33'53.89\"N \n37°12'25.7\"W",
                        "charNo": 1,
                        "characteristic": "Fl.W.\nperiod 5s \nfl. 1.0s, ec. 4.0s \n",
                        "heightFeetMeters": "36\n11",
                        "range": "7",
                        "structure": "Yellow pedestal, red band; 7.\n",
                        "remarks": nil,
                        "postNote": nil,
                        "noticeNumber": 201507,
                        "removeFromList": "N",
                        "deleteFlag": "Y",
                        "noticeWeek": "07",
                        "noticeYear": "2015"
                    ],
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Lighted Aids",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": nil,
                        "subregionHeading": nil,
                        "localHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": "6",
                        "name": "Kulusuk, NW Coast, RACON.",
                        "position": "65°33'53.89\"N \n37°12'25.7\"W",
                        "charNo": 1,
                        "characteristic": "T(- )\nperiod 60s \n",
                        "heightFeetMeters": nil,
                        "range": nil,
                        "structure": nil,
                        "remarks": "(3 & 10cm).\n",
                        "postNote": nil,
                        "noticeNumber": 201507,
                        "removeFromList": "N",
                        "deleteFlag": "Y",
                        "noticeWeek": "07",
                        "noticeYear": "2015"
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        let lights = await dataSource.fetch(task: nil, volume: "PUB 110", noticeYear: "2015", noticeWeek: "08")

        XCTAssertEqual(lights.count, 2)
    }

}
