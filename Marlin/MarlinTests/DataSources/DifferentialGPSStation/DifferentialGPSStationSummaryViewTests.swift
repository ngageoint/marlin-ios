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
    func testLoading() {
        var newItem = DGPSStationModel()
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
        newItem.canBookmark = true

        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        localDataSource.list = [newItem]
        let repository = DGPSStationRepository(localDataSource: localDataSource, remoteDataSource: DGPSStationRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(dgpsRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)
        
        let summary = DGPSStationSummaryView(dgpsStation: DGPSStationListModel(dgpsStationModel: newItem))
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(MarlinRouter())

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
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkStaticRepository, bookmarkable: newItem)
    }
    
    func testLoadingNoVolume() {
        var newItem = DGPSStationModel()
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
        newItem.canBookmark = true

        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        localDataSource.list = [newItem]
        let repository = DGPSStationRepository(localDataSource: localDataSource, remoteDataSource: DGPSStationRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(dgpsRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summary = DGPSStationSummaryView(dgpsStation: DGPSStationListModel(dgpsStationModel: newItem))
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
            let dgpsKeys = tapNotification.itemKeys!

            let dgps = dgpsKeys[DataSources.dgps.key]!

            XCTAssertEqual(dgps.count, 1)
            XCTAssertEqual(dgps[0], newItem.itemKey)
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
        var newItem = DGPSStationModel()
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
        
        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        localDataSource.list = [newItem]
        let repository = DGPSStationRepository(localDataSource: localDataSource, remoteDataSource: DGPSStationRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(dgpsRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)
        let router = MarlinRouter()

        let summary = DGPSStationSummaryView(dgpsStation: DGPSStationListModel(dgpsStationModel: newItem))
            .setShowMoreDetails(true)
            .setShowSectionHeader(true)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(router)

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "6 PUB 112")
        tester().waitForView(withAccessibilityLabel: "KOREA")
        tester().waitForView(withAccessibilityLabel: "KOREA: region heading")
        tester().waitForView(withAccessibilityLabel: "T670\nR740\nR741")
        tester().waitForView(withAccessibilityLabel: "Message types: 3, 5, 7, 9, 16.")
        
        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 1)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
}
