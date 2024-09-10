//
//  ChartCorrectionListViewModelTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/7/22.
//

import XCTest
import CoreLocation
import OHHTTPStubs
import SwiftUI

@testable import Marlin

extension XCTestCase {
    /// Creates an expectation for monitoring the given condition.
    /// - Parameters:
    ///   - condition: The condition to evaluate to be `true`.
    ///   - description: A string to display in the test log for this expectation, to help diagnose failures.
    /// - Returns: The expectation for matching the condition.
    func expectation(for condition: @autoclosure @escaping () -> Bool, description: String = "") -> XCTestExpectation {
        let predicate = NSPredicate { _, _ in
            return condition()
        }
        
        return XCTNSPredicateExpectation(predicate: predicate, object: nil)
    }
}

final class ChartCorrectionListViewModelTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [])
        LocationManager.shared().lastLocation = nil
    }
    
    override func tearDown() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [])
        LocationManager.shared().lastLocation = nil
    }
    
    func testNoFilters() {
        let model = ChartCorrectionListViewModel()
        XCTAssertEqual(model.createQueryParameters(), nil)
    }
    
    func testNoticeNumberEquals() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int), comparison: .equals, valueInt: 202104),DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        let model = ChartCorrectionListViewModel()
        XCTAssertEqual(model.createQueryParameters()?.sorted(), ["output=json", "noticeNumber=202104", "latitudeLeft=1.983373251615157", "latitudeRight=2.0166265798958665", "longitudeRight=3.0166367990618945", "longitudeLeft=2.9833632009381055"].sorted())
    }
    
    func testNoticeNumberLessThan() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int), comparison: .lessThan, valueInt: 202101), DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        let model = ChartCorrectionListViewModel()
        XCTAssertEqual(model.createQueryParameters()?.sorted(), ["output=json", "maxNoticeNumber=202052", "minNoticeNumber=199929", "latitudeLeft=1.983373251615157", "latitudeRight=2.0166265798958665", "longitudeRight=3.0166367990618945", "longitudeLeft=2.9833632009381055"].sorted())
    }
    
    func testNoticeNumberLessThanEqual() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int), comparison: .lessThanEqual, valueInt: 202101), DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        let model = ChartCorrectionListViewModel()
        XCTAssertEqual(model.createQueryParameters()?.sorted(), ["output=json", "maxNoticeNumber=202101", "minNoticeNumber=199929", "latitudeLeft=1.983373251615157", "latitudeRight=2.0166265798958665", "longitudeRight=3.0166367990618945", "longitudeLeft=2.9833632009381055"].sorted())
    }

    func testNoticeNumberGreaterThan() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int), comparison: .greaterThan, valueInt: 202052), DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        let model = ChartCorrectionListViewModel()
        let calendar = Calendar.current
        let thisWeek = calendar.component(.weekOfYear, from: Date())
        let thisYear = calendar.component(.year, from: Date())
        XCTAssertEqual(model.createQueryParameters()?.sorted(), ["output=json", "maxNoticeNumber=\(thisYear)\(String(format: "%02d", thisWeek))", "minNoticeNumber=202101", "latitudeLeft=1.983373251615157", "latitudeRight=2.0166265798958665", "longitudeRight=3.0166367990618945", "longitudeLeft=2.9833632009381055"].sorted())
    }
    
    func testNoticeNumberGreaterThanEqual() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int), comparison: .greaterThanEqual, valueInt: 202052), DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        let model = ChartCorrectionListViewModel()
        let calendar = Calendar.current
        let thisWeek = calendar.component(.weekOfYear, from: Date())
        let thisYear = calendar.component(.year, from: Date())
        XCTAssertEqual(model.createQueryParameters()?.sorted(), ["output=json", "maxNoticeNumber=\(thisYear)\(String(format: "%02d", thisWeek))", "minNoticeNumber=202052", "latitudeLeft=1.983373251615157", "latitudeRight=2.0166265798958665", "longitudeRight=3.0166367990618945", "longitudeLeft=2.9833632009381055"].sorted())
    }
    
    func testLocationCloseTo() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        let model = ChartCorrectionListViewModel()

        XCTAssertEqual(model.createQueryParameters()?.sorted(), ["output=json", "latitudeLeft=1.983373251615157", "latitudeRight=2.0166265798958665", "longitudeRight=3.0166367990618945", "longitudeLeft=2.9833632009381055"].sorted())
    }
    
    func testLocationNearMeNoLocation() {
        LocationManager.shared().lastLocation = nil
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .nearMe, valueInt: 1)])
        let model = ChartCorrectionListViewModel()
        
        XCTAssertNil(model.createQueryParameters())
    }
    
    func testLocationNearMe() {
        LocationManager.shared().lastLocation = CLLocation(latitude: 2.0, longitude: 3.0)
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .nearMe, valueInt: 1)])
        let model = ChartCorrectionListViewModel()
        
        XCTAssertEqual(model.createQueryParameters()?.sorted(), ["output=json", "latitudeLeft=1.983373251615157", "latitudeRight=2.0166265798958665", "longitudeRight=3.0166367990618945", "longitudeLeft=2.9833632009381055"].sorted())
    }
    
    func testLoadDataNoLocation() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .nearMe, valueInt: 1)])
        let model = ChartCorrectionListViewModel()
        let publishExpectation = expectation(for: model.queryError != nil)
        model.loadData()
        wait(for: [publishExpectation], timeout: 10.0)
        XCTAssertEqual("Invalid Chart Correction Query Parameters", model.queryError)
        XCTAssertFalse(model.loading)
    }
    
    func testLoadDataLocation() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        let model = ChartCorrectionListViewModel()
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/ntm/ntm-chart-corr/geo") && containsQueryParams(["latitudeLeft": "1.983373251615157", "latitudeRight":"2.0166265798958665", "longitudeRight":"3.0166367990618945", "longitudeLeft":"2.9833632009381055"])) { request in
            XCTAssertTrue(model.loading)
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("chartCorrections.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        let publishExpectation = expectation(for: !model.results.isEmpty)
        model.loadData()
        wait(for: [publishExpectation], timeout: 10.0)
        XCTAssertEqual(model.results.count, 2)
        XCTAssertEqual(model.sortedChartIds, ["12", "104"])
        XCTAssertEqual(model.sortedChartCorrections(key: "104")?.count, 7)
        XCTAssertEqual(model.sortedChartCorrections(key: "12")?.count, 2)
        XCTAssertNil(model.queryError)
        XCTAssertFalse(model.loading)
    }
    
    func testListView() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/ntm/ntm-chart-corr/geo")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("chartCorrections.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }

        struct Container: View {
            @State var router: MarlinRouter = MarlinRouter()
            @State var view = ChartCorrectionList()
            var body: some View {
                NavigationStack(path: $router.path) {
                    view.marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let container = Container()
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        let publishExpectation = expectation(for: !container.view.viewModel.sortedChartIds.isEmpty)
        wait(for: [publishExpectation], timeout: 10.0)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Querying...")
        
        XCTAssertEqual(container.view.viewModel.sortedChartIds, ["12", "104"])

        XCTAssertEqual(container.view.viewModel.sortedChartCorrections(key: "12")?.count, 2)
        XCTAssertEqual(container.view.viewModel.sortedChartCorrections(key: "104")?.count, 7)

        // verify the things that should be here
        // tap the rows
        tester().waitForView(withAccessibilityLabel: "104")
        tester().tapView(withAccessibilityLabel: "104")
        
        tester().waitForView(withAccessibilityLabel: "NTM 20/06 Details")
        tester().tapView(withAccessibilityLabel: "NTM 20/06 Details")
        
        tester().waitForView(withAccessibilityLabel: "Notice 6/20")
    }
    
    func testLoadDataError() {
        UserDefaults.standard.setFilter(ChartCorrection.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)])
        let model = ChartCorrectionListViewModel()
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/ntm/ntm-chart-corr/geo")) { request in
            XCTAssertTrue(model.loading)
            let notConnectedError = NSError(domain:NSURLErrorDomain, code:Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue), userInfo:nil)
            return HTTPStubsResponse(error:notConnectedError)
        }
        
        let publishExpectation = expectation(for: model.queryError != nil)
        model.loadData()
        wait(for: [publishExpectation], timeout: 10.0)
        XCTAssertTrue(model.results.isEmpty)
        XCTAssertEqual(model.queryError, "URLSessionTask failed with error: The operation couldn’t be completed. (NSURLErrorDomain error -1009.)")
        XCTAssertFalse(model.loading)
    }

}
