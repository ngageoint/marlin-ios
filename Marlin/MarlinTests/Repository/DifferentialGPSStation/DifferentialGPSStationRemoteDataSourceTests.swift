//
//  DifferentialGPSStationRemoteDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import OHHTTPStubs
import Combine

@testable import Marlin

final class DifferentialGPSStationRemoteDataSourceTests: XCTestCase {

    override class func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }

    func testFetchDifferentialGPSStationsWithoutTask() async {
        let dataSource = DGPSStationRemoteDataSourceImpl()

        stub(condition: isScheme("https") && pathEndsWith("/publications/ngalol/dgpsstations")) { request in
            let jsonObject = [
                "ngalol": [
                    [
                        "volumeNumber": "PUB 112",
                        "aidType": "Differential GPS Stations",
                        "geopoliticalHeading": "KOREA",
                        "regionHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": 6,
                        "name": "Chojin Dan Lt",
                        "position": "38°33'09\"N \n128°23'53.99\"E",
                        "stationID": "T670\nR740\nR741\n",
                        "range": 100,
                        "frequency": 292,
                        "transferRate": 200,
                        "remarks": "Message types: 3, 5, 7, 9, 16.",
                        "postNote": nil,
                        "noticeNumber": 201134,
                        "removeFromList": "N",
                        "deleteFlag": "N",
                        "noticeWeek": "34",
                        "noticeYear": "2011"
                    ],
                    [
                        "volumeNumber": "PUB 112",
                        "aidType": "Differential GPS Stations",
                        "geopoliticalHeading": "KOREA",
                        "regionHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": 7,
                        "name": "Chumunjin Dan",
                        "position": "37°53'52.21\"N \n128°50'01.79\"E",
                        "stationID": "T663\nR726\nR727\n",
                        "range": 100,
                        "frequency": 295,
                        "transferRate": 200,
                        "remarks": "Message types: 3, 5, 7, 9, 16.",
                        "postNote": nil,
                        "noticeNumber": 201134,
                        "removeFromList": "N",
                        "deleteFlag": "N",
                        "noticeWeek": "34",
                        "noticeYear": "2011"
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        let dgpss = await dataSource.fetch()

        XCTAssertEqual(dgpss.count, 2)
        let newDgps = dgpss[0]

        XCTAssertEqual(newDgps.featureNumber, 6)
        XCTAssertEqual(newDgps.volumeNumber, "PUB 112")
    }
}
