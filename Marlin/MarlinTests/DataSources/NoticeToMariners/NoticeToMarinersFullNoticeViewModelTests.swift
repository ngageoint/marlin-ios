//
//  NoticeToMarinersFullNoticeViewModelTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/8/22.
//

import XCTest
import OHHTTPStubs

@testable import Marlin

final class NoticeToMarinersFullNoticeViewModelTests: XCTestCase {

    func testCreateFetchRequestNoticeNumber() {
        let model = NoticeToMarinersFullNoticeViewViewModel()
        model.setupModel(noticeNumber: 202201)
        XCTAssertEqual(model.noticeNumber, 202201)
        XCTAssertEqual(model.noticeNumberString, "22/1")
//        XCTAssertEqual(model.predicate, NSPredicate(format: "noticeNumber == %i", argumentArray: [202201]))
    }
    
    func testCreateFetchRequestNoticeNumberString() {
        let model = NoticeToMarinersFullNoticeViewViewModel()
        model.setupModel(noticeNumberString: "51/22")
        XCTAssertEqual(model.noticeNumber, 202251)
        XCTAssertEqual(model.noticeNumberString, "22/51")
//        XCTAssertEqual(model.predicate, NSPredicate(format: "noticeNumber == %i", argumentArray: [202251]))
    }
    
    func testCreateFetchRequestNoticeNumberStringOneDigitWeek() {
        let model = NoticeToMarinersFullNoticeViewViewModel()
        model.setupModel(noticeNumberString: "1/22")
        XCTAssertEqual(model.noticeNumber, 202201)
        XCTAssertEqual(model.noticeNumberString, "22/1")
//        XCTAssertEqual(model.predicate, NSPredicate(format: "noticeNumber == %i", argumentArray: [202201]))
    }
    
    func testCreateFetchRequestNoticeNumberString1999() {
        let model = NoticeToMarinersFullNoticeViewViewModel()
        model.setupModel(noticeNumberString: "51/99")
        XCTAssertEqual(model.noticeNumber, 199951)
        XCTAssertEqual(model.noticeNumberString, "99/51")
//        XCTAssertEqual(model.predicate, NSPredicate(format: "noticeNumber == %i", argumentArray: [199951]))
        let sort = DataSources.noticeToMariners.defaultSort.reduce(into: []) { sorts, parameter in
            sorts.append(parameter.toNSSortDescriptor())
        }
        
//        XCTAssertEqual(model.sortDescriptors, sort)
    }
    
    func testLoadGraphics() {
        let model = NoticeToMarinersFullNoticeViewViewModel()
        model.setupModel(noticeNumber: 202020)

        stub(condition: isScheme("https") && pathEndsWith("/publications/ntm/ntm-graphics") && containsQueryParams(["noticeNumber": "202020", "output":"json", "graphicType":"All"])) { request in
            XCTAssertTrue(model.loadingGraphics)
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("ntmGraphics.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        let publishExpectation = expectation(for: !model.graphics.isEmpty)
        model.loadGraphics()
        wait(for: [publishExpectation], timeout: 10.0)
        XCTAssertFalse(model.graphics.isEmpty)
        XCTAssertEqual(model.graphics.count, 3)
        let depthTabs = model.graphics["Depth Tab"]
        XCTAssertEqual(depthTabs?.count, 5)
        
        let notes = model.graphics["Note"]
        XCTAssertEqual(notes?.count, 7)
        
        let charlets = model.graphics["Chartlet"]
        XCTAssertEqual(charlets?.count, 1)
        
        XCTAssertEqual(model.sortedGraphicKeys, ["Chartlet", "Depth Tab", "Note"])
    }
}
