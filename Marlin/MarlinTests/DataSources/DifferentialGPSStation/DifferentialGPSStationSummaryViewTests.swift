//
//  DifferentialGPSStationSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/12/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class DifferentialGPSStationSummaryViewTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource.definition)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
    }
    
    override func tearDown() {
    }
    
    func testLoading() {
        let newItem = DifferentialGPSStation(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 112"
        newItem.aidType = "Differential GPS Stations"
        newItem.geopoliticalHeading = "KOREA"
        newItem.regionHeading = "region heading"
        newItem.precedingNote = "preceeding note"
        newItem.featureNumber = 6
        newItem.name = "Chojin Dan Lt"
        newItem.position = "1°00'00\"N \n2°00'00.00\"E"
        newItem.latitude = 1.0
        newItem.longitude = 2.0
        newItem.stationID = "T670\nR740\nR741"
        newItem.range = 100
        newItem.frequency = 292
        newItem.transferRate = 200
        newItem.remarks = "Message types: 3, 5, 7, 9, 16."
        newItem.postNote = "post note"
        newItem.noticeNumber = 201134
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "34"
        newItem.noticeYear = "2011"
        
        let repository = DifferentialGPSStationRepositoryManager(repository: DifferentialGPSStationCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summary = newItem.summary
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "6 PUB 112")
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: newItem.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: newItem.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: newItem)
    }
    
    func testLoadingNoVolume() {
        let newItem = DifferentialGPSStation(context: persistentStore.viewContext)
        newItem.volumeNumber = nil
        newItem.aidType = "Differential GPS Stations"
        newItem.geopoliticalHeading = "KOREA"
        newItem.regionHeading = "region heading"
        newItem.precedingNote = "preceeding note"
        newItem.featureNumber = 6
        newItem.name = "Chojin Dan Lt"
        newItem.position = "1°00'00\"N \n2°00'00.00\"E"
        newItem.latitude = 1.0
        newItem.longitude = 2.0
        newItem.stationID = "T670\nR740\nR741"
        newItem.range = 100
        newItem.frequency = 292
        newItem.transferRate = 200
        newItem.remarks = "Message types: 3, 5, 7, 9, 16."
        newItem.postNote = "post note"
        newItem.noticeNumber = 201134
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "34"
        newItem.noticeYear = "2011"
        
        let repository = DifferentialGPSStationRepositoryManager(repository: DifferentialGPSStationCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summary = newItem.summary
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "6 ")
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: newItem.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: newItem.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }

        expectation(forNotification: .MapItemsTapped, object: nil) { notification in

            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let dgps = tapNotification.items as! [DifferentialGPSStationModel]
            XCTAssertEqual(dgps.count, 1)
            XCTAssertEqual(dgps[0].featureNumber, 6)
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")

        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapView(withAccessibilityLabel: "dismiss popup")
    }
    
    func testLoadingShowMoreDetails() {
        let newItem = DifferentialGPSStation(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 112"
        newItem.aidType = "Differential GPS Stations"
        newItem.geopoliticalHeading = "KOREA"
        newItem.regionHeading = "region heading"
        newItem.sectionHeader = "KOREA: region heading"
        newItem.precedingNote = "preceeding note"
        newItem.featureNumber = 6
        newItem.name = "Chojin Dan Lt"
        newItem.position = "1°00'00\"N \n2°00'00.00\"E"
        newItem.latitude = 1.0
        newItem.longitude = 2.0
        newItem.stationID = "T670\nR740\nR741"
        newItem.range = 100
        newItem.frequency = 292
        newItem.transferRate = 200
        newItem.remarks = "Message types: 3, 5, 7, 9, 16."
        newItem.postNote = "post note"
        newItem.noticeNumber = 201134
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "34"
        newItem.noticeYear = "2011"
        
        let repository = DifferentialGPSStationRepositoryManager(repository: DifferentialGPSStationCoreDataRepository(context: persistentStore.viewContext))
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summary = newItem.summary
            .setShowMoreDetails(true)
            .setShowSectionHeader(true)
            .environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "6 PUB 112")
        tester().waitForView(withAccessibilityLabel: "KOREA")
        tester().waitForView(withAccessibilityLabel: "KOREA: region heading")
        tester().waitForView(withAccessibilityLabel: "T670\nR740\nR741")
        tester().waitForView(withAccessibilityLabel: "Message types: 3, 5, 7, 9, 16.")
        
        expectation(forNotification: .ViewDataSource,
                    object: nil) { notification in
            let vds = try! XCTUnwrap(notification.object as? ViewDataSource)
            let dgps = try! XCTUnwrap(vds.dataSource as? DifferentialGPSStationModel)
            XCTAssertEqual(dgps.featureNumber, 6)
            return true
        }
        tester().tapView(withAccessibilityLabel: "More Details")

        waitForExpectations(timeout: 10, handler: nil)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
}
