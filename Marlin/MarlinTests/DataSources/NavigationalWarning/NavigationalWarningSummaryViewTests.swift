//
//  NavigationalWarningSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningSummaryViewTests: XCTestCase {

    func testLoading() {
        var nw = NavigationalWarningModel(navArea: "P")

        nw.cancelMsgNumber = 1
        nw.authority = "authority"
        nw.cancelDate = Date(timeIntervalSince1970: 0)
        nw.cancelMsgYear = 2020
        nw.cancelNavArea = "P"
        nw.issueDate = Date(timeIntervalSince1970: 0)
        nw.msgNumber = 2
        nw.msgYear = 2019
        nw.navArea = "P"
        nw.status = "status"
        nw.subregion = "subregion"
        nw.text = "text of the warning"
        nw.canBookmark = true

        let localDataSource = NavigationalWarningStaticLocalDataSource()
        localDataSource.list.append(nw)
        let repository = NavigationalWarningRepository(localDataSource: localDataSource, remoteDataSource: NavigationalWarningRemoteDataSource())

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource, navigationalWarningRepository: repository)
        let summary = NavigationalWarningSummaryView(navigationalWarning: nw)
            .setShowMoreDetails(false)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "HYDROPAC 2/2019 (subregion)")
        tester().waitForView(withAccessibilityLabel: "text of the warning")
        tester().waitForView(withAccessibilityLabel: nw.dateString)
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapView(withAccessibilityLabel: "dismiss popup")
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkRepository, bookmarkable: nw)

    }
}
