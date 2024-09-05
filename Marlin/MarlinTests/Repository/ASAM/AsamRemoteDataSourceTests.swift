//
//  AsamRemoteDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/7/23.
//

import XCTest
import OHHTTPStubs
import Combine

@testable import Marlin

final class AsamRemoteDataSourceTests: XCTestCase {
        
    override func setUpWithError() throws {
        throw XCTSkip("ASAMs are disabled.")
        
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }
    
    func testFetchAsamsWithoutTask() async {
        let dataSource = AsamRemoteDataSource()
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/asam")) { request in
            let jsonObject = [
                "asam": [
                    [
                        "reference": "2022-218",
                        "date": "2022-10-24",
                        "latitude": 1.1499999999778083,
                        "longitude": 103.43333333315655,
                        "position": "1°09'00\"N \n103°26'00\"E",
                        "navArea": "XI",
                        "subreg": "71",
                        "hostility": "Boarding",
                        "victim": "Marshall Islands bulk carrier GENCO ENDEAVOUR",
                        "description": "THIS ONE IS NEW"
                    ],
                    [
                        "reference": "2022-216",
                        "date": "2022-10-21",
                        "latitude": 14.649999999964734,
                        "longitude": 49.49999999969782,
                        "position": "14°39'00\"N \n49°30'00\"E",
                        "navArea": "IX",
                        "subreg": "62",
                        "hostility": "Two drone explosions",
                        "victim": "Marshall Islands-flagged oil tanker NISSOS KEA",
                        "description": "UPDATED"
                    ],
                    // this one is the same
                    [
                        "reference": "2022-217",
                        "date": "2022-10-24",
                        "latitude": 1.1499999999778083,
                        "longitude": 103.43333333315655,
                        "position": "1°09'00\"N \n103°26'00\"E",
                        "navArea": "XI",
                        "subreg": "71",
                        "hostility": "Boarding",
                        "victim": "Marshall Islands bulk carrier GENCO ENDEAVOUR",
                        "description": "INDONESIA: On 23 October at 2359 local time, five robbers boarded the underway Marshall Islands-flagged bulk carrier GENCO ENDEAVOUR close to Little Karimum Island in the eastbound lane of the Singapore Strait Traffic Separation Scheme (TSS), near position 01-09N 103-26E. The crew sighted the unauthorized personnel near the steering gear room and activated the ship’s general alarm. Upon realizing they had been discovered, the robbers escaped empty-handed. The ship reported the incident to the Singapore Vessel Traffic System. The Singapore police coast guard later boarded the vessel for an investigation. Information was shared with Indonesian authorities."
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let asams = await dataSource.fetch()
        
        XCTAssertEqual(asams.count, 3)
        let newAsam = asams[0]
        
        XCTAssertEqual(newAsam.reference, "2022-218")
        XCTAssertEqual(newAsam.asamDescription, "THIS ONE IS NEW")
    }
}
