//
//  LightSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/18/23.
//

import XCTest

import Combine
import SwiftUI

@testable import Marlin

final class LightSummaryViewTests: XCTestCase {

    func testLoading() {
        var light = LightModel()

        light.characteristicNumber = 1
        light.volumeNumber = "PUB 110"
        light.featureNumber = "14840"
        light.noticeWeek = "06"
        light.noticeYear = "2015"
        light.latitude = 1.0
        light.longitude = 2.0
        light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
        light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
        light.range = "W. 12 ; R. 9 ; G. 9"
        light.sectionHeader = "Section"
        light.structure = "Yellow pedestal, red band; 7.\n"
        light.name = "-Outer."
        light.canBookmark = true

        let localDataSource = LightStaticLocalDataSource()
        let remoteDataSource = LightRemoteDataSource()
        InjectedValues[\.lightLocalDataSource] = localDataSource
        InjectedValues[\.lightRemoteDataSource] = remoteDataSource
        localDataSource.list = [light]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource)

        let summary = LightSummaryView(light: LightListModel(lightModel: light))
            .setShowMoreDetails(false)
            .environmentObject(bookmarkRepository)
            .environmentObject(MarlinRouter())

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "14840  PUB 110")
        tester().waitForView(withAccessibilityLabel: "-Outer.")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Section")
        tester().waitForView(withAccessibilityLabel: "Yellow pedestal, red band; 7.")
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: light.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: light.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let lightKeys = tapNotification.itemKeys!

            let lights = lightKeys[DataSources.light.key]!

            XCTAssertEqual(lights.count, 1)
            XCTAssertEqual(lights[0], light.itemKey)
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapScreen(at: CGPoint(x:20, y:20))
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkRepository, bookmarkable: light)
    }
    
    func testShowMoreDetails() {
        var light = LightModel()

        light.characteristicNumber = 1
        light.volumeNumber = "PUB 110"
        light.featureNumber = "14840"
        light.noticeWeek = "06"
        light.noticeYear = "2015"
        light.latitude = 1.0
        light.longitude = 2.0
        light.remarks = "R. 120°-163°, W.-170°, G.-200°.\n"
        light.characteristic = "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n"
        light.range = "W. 12 ; R. 9 ; G. 9"
        light.sectionHeader = "Section"
        light.structure = "Yellow pedestal, red band; 7.\n"
        light.name = "-Outer."
        light.canBookmark = true

        let router = MarlinRouter()
        let localDataSource = LightStaticLocalDataSource()
        let remoteDataSource = LightRemoteDataSource()
        InjectedValues[\.lightLocalDataSource] = localDataSource
        InjectedValues[\.lightRemoteDataSource] = remoteDataSource
        localDataSource.list = [light]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource)

        let summary = LightSummaryView(light: LightListModel(lightModel: light))
            .setShowMoreDetails(true)
            .environmentObject(bookmarkRepository)
            .environmentObject(router)

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "14840  PUB 110")
        tester().waitForView(withAccessibilityLabel: "-Outer.")
        tester().waitForView(withAccessibilityLabel: "Section")
        tester().waitForView(withAccessibilityLabel: "Yellow pedestal, red band; 7.")
        
        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 1)

        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
}
