//
//  AsamSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/20/22.
//

import XCTest
import SwiftUI

@testable import Marlin

final class AsamSummaryViewTests: XCTestCase {
    override func setUp() {
        for dataSource in DataSourceDefinitions.allCases {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(dataSource.definition)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }
    
    override func tearDown() {
    }

    func testLoading() {
        var asam = AsamModel()
        asam.asamDescription = "description"
        asam.longitude = 1.0
        asam.latitude = 1.0
        asam.date = Date()
        asam.navArea = "XI"
        asam.reference = "2022-100"
        asam.subreg = "71"
        asam.position = "1°00'00\"N \n1°00'00\"E"
        asam.hostility = "Boarding"
        asam.victim = "Boat"
        asam.canBookmark = true

        let localDataSource = AsamStaticLocalDataSource()
        localDataSource.asamList = [asam]
        let repository = AsamRepository(localDataSource: localDataSource, remoteDataSource: AsamRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(asamRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)
        
        let summary = AsamSummaryView(asam: AsamListModel(asamModel:asam))
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkStaticRepository, bookmarkable: asam)
    }
    
    func testLoadingNoHostility() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = nil
        newItem.victim = "Boat"
        
        let localDataSource = AsamStaticLocalDataSource()
        localDataSource.asamList = [newItem]
        let repository = AsamRepository(localDataSource: localDataSource, remoteDataSource: AsamRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(asamRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summary = AsamSummaryView(asam: AsamListModel(asamModel:newItem))
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadingNoVictim() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = nil
        
        let localDataSource = AsamStaticLocalDataSource()
        localDataSource.asamList = [newItem]
        let repository = AsamRepository(localDataSource: localDataSource, remoteDataSource: AsamRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(asamRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summary = AsamSummaryView(asam: AsamListModel(asamModel:newItem))
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadingShowMoreDetails() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        let router = MarlinRouter()
        let localDataSource = AsamStaticLocalDataSource()
        localDataSource.asamList = [newItem]
        let repository = AsamRepository(localDataSource: localDataSource, remoteDataSource: AsamRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(asamRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summary = AsamSummaryView(asam: AsamListModel(asamModel:newItem), showMoreDetails: true)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(router)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()

        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 1)

        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
    
    func testLoadingShowMoreDetailsFalse() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        let router = MarlinRouter()
        let localDataSource = AsamStaticLocalDataSource()
        localDataSource.asamList = [newItem]
        let repository = AsamRepository(localDataSource: localDataSource, remoteDataSource: AsamRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(asamRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summary = AsamSummaryView(asam: AsamListModel(asamModel:newItem), showMoreDetails: false)
//        let summary = AsamSummaryView(asam: AsamListModel(asam: newItem), showMoreDetails: false)
            .environmentObject(repository)
            .environmentObject(MarlinRouter())
            .environmentObject(bookmarkRepository)
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "focus")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let asams = tapNotification.itemKeys![DataSources.asam.key] as! [String]
            XCTAssertEqual(asams.count, 1)
            XCTAssertEqual(asams[0], "2022-100")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapView(withAccessibilityLabel: "dismiss popup")
    }

}
