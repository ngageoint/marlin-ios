//
//  NoticeToMarinersSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/27/23.
//

import XCTest
import OHHTTPStubs
import SwiftUI
import Combine

@testable import Marlin

@MainActor
final class NoticeToMarinersSummaryViewTests: XCTestCase {

    func testFileSummaryView() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var ntm = NoticeToMarinersModel()

        ntm.publicationIdentifier = 41791
        ntm.noticeNumber = 202247
        ntm.title = "Front Cover"
        ntm.odsKey = "16694429/SFH00000/UNTM/202247/Front_Cover.pdf"
        ntm.sectionOrder = 20
        ntm.limitedDist = false
        ntm.odsEntryId = 29431
        ntm.odsContentId = 16694429
        ntm.internalPath = "UNTM/202247"
        ntm.filenameBase = "Front_Cover"
        ntm.fileExtension = "pdf"
        ntm.fileSize = 63491
        ntm.isFullPublication = false
        ntm.uploadTime = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
        ntm.lastModified = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")

        let localDataSource = NoticeToMarinersStaticLocalDataSource()
        localDataSource.map[ntm.odsEntryId ?? -1] = ntm
        localDataSource.deleteFile(odsEntryId: ntm.odsEntryId ?? -1)
        let remoteDataSource = NoticeToMarinersRemoteDataSourceImpl()
        InjectedValues[\.ntmLocalDataSource] = localDataSource
        InjectedValues[\.ntmRemoteDataSource] = remoteDataSource
        let repository = NoticeToMarinersRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let summaryView = NoticeToMarinersFileSummaryView(odsEntryId: ntm.odsEntryId!)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Front Cover")
        tester().waitForView(withAccessibilityLabel: "File Size: 63 KB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(ntm.uploadTime!.formatted(date: .complete, time: .omitted))")
    }
    
    func testSummary() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var ntm = NoticeToMarinersModel()

        ntm.publicationIdentifier = 41791
        ntm.noticeNumber = 202247
        ntm.title = "Front Cover"
        ntm.odsKey = "16694429/SFH00000/UNTM/202247/Front_Cover.pdf"
        ntm.sectionOrder = 20
        ntm.limitedDist = false
        ntm.odsEntryId = 29431
        ntm.odsContentId = 16694429
        ntm.internalPath = "UNTM/202247"
        ntm.filenameBase = "Front_Cover"
        ntm.fileExtension = "pdf"
        ntm.fileSize = 63491
        ntm.isFullPublication = false
        ntm.uploadTime = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
        ntm.lastModified = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")

        let localDataSource = NoticeToMarinersStaticLocalDataSource()
        localDataSource.map[ntm.odsEntryId ?? -1] = ntm
        localDataSource.deleteFile(odsEntryId: ntm.odsEntryId ?? -1)
        let remoteDataSource = NoticeToMarinersRemoteDataSourceImpl()
        InjectedValues[\.ntmLocalDataSource] = localDataSource
        InjectedValues[\.ntmRemoteDataSource] = remoteDataSource
        let repository = NoticeToMarinersRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let summaryView = NoticeToMarinersSummaryView(noticeToMariners: NoticeToMarinersListModel(noticeToMarinersModel: ntm))
            .environmentObject(MarlinRouter())

        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "202247")
        tester().waitForView(withAccessibilityLabel: "November 19 - November 25")
        
        try await BookmarkHelper().verifyBookmarkButton(bookmarkable: ntm)
    }
    
    func testReDownloadFullPublication() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var ntm = NoticeToMarinersModel()

        ntm.publicationIdentifier = 41791
        ntm.noticeNumber = 202247
        ntm.title = "Front Cover"
        ntm.odsKey = "16694429/SFH00000/UNTM/202247/Front_Cover.pdf"
        ntm.sectionOrder = 20
        ntm.limitedDist = false
        ntm.odsEntryId = 29431
        ntm.odsContentId = 16694429
        ntm.internalPath = "UNTM/202247"
        ntm.filenameBase = "Front_Cover"
        ntm.fileExtension = "pdf"
        ntm.fileSize = 63491
        ntm.isFullPublication = true
        ntm.uploadTime = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
        ntm.lastModified = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")
        ntm.isDownloaded = false
        ntm.isDownloading = true

        let localDataSource = NoticeToMarinersStaticLocalDataSource()
        localDataSource.map[ntm.odsEntryId ?? -1] = ntm
        localDataSource.deleteFile(odsEntryId: ntm.odsEntryId ?? -1)
        let remoteDataSource = NoticeToMarinersRemoteDataSourceImpl()
        InjectedValues[\.ntmLocalDataSource] = localDataSource
        InjectedValues[\.ntmRemoteDataSource] = remoteDataSource
        @Injected(\.ntmRepository)
        var repository: NoticeToMarinersRepository
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let summaryView = NoticeToMarinersFileSummaryView(odsEntryId: ntm.odsEntryId!)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Front Cover pdf")
        tester().waitForView(withAccessibilityLabel: "File Size: 63 KB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(ntm.uploadTime!.formatted(date: .complete, time: .omitted))")

        stub(condition: isScheme("https") && pathEndsWith("api/publications/download")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("mockEpub.rtf", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/rtf"]
            )
        }
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "Cancel")
        tester().tapView(withAccessibilityLabel: "Cancel")
        tester().waitForView(withAccessibilityLabel: "Download")
        tester().tapView(withAccessibilityLabel: "Download")
        
        XCTFail("Figure out how to test async")
//        let progressExpectation = expectation(for: repository.getNoticeToMariners(odsEntryId: ntm.odsEntryId!)?.downloadProgress == 1.0)
//
//        wait(for: [progressExpectation], timeout: 5)
//
//        expectation(forNotification: .DocumentPreview,
//                    object: nil) { notification in
//            let model: URL = try! XCTUnwrap(notification.object as? URL)
//            XCTAssertEqual(model.path, URL(string: ntm.savePath)!.path)
//            return true
//        }
//
//        tester().waitForView(withAccessibilityLabel: "Open")
//        tester().tapView(withAccessibilityLabel: "Open")
//        waitForExpectations(timeout: 10, handler: nil)
//        
//        XCTAssertTrue(repository.checkFileExists(odsEntryId: ntm.odsEntryId ?? -1))
//        tester().tapView(withAccessibilityLabel: "Delete")
//        XCTAssertFalse(repository.checkFileExists(odsEntryId: ntm.odsEntryId ?? -1))
    }
    
    func testDownloadFullPublication() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var ntm = NoticeToMarinersModel()

        ntm.publicationIdentifier = 41791
        ntm.noticeNumber = 202247
        ntm.title = "Front Cover"
        ntm.odsKey = "16694429/SFH00000/UNTM/202247/Front_Cover.pdf"
        ntm.sectionOrder = 20
        ntm.limitedDist = false
        ntm.odsEntryId = 29431
        ntm.odsContentId = 16694429
        ntm.internalPath = "UNTM/202247"
        ntm.filenameBase = "Front_Cover"
        ntm.fileExtension = "pdf"
        ntm.fileSize = 63491
        ntm.isFullPublication = true
        ntm.uploadTime = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
        ntm.lastModified = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")
        ntm.isDownloaded = false
        ntm.isDownloading = false

        let localDataSource = NoticeToMarinersStaticLocalDataSource()
        localDataSource.map[ntm.odsEntryId ?? -1] = ntm
        localDataSource.deleteFile(odsEntryId: ntm.odsEntryId ?? -1)
        let remoteDataSource = NoticeToMarinersRemoteDataSourceImpl()
        InjectedValues[\.ntmLocalDataSource] = localDataSource
        InjectedValues[\.ntmRemoteDataSource] = remoteDataSource
        
        @Injected(\.ntmRepository)
        var repository: NoticeToMarinersRepository
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let summaryView = NoticeToMarinersFileSummaryView(odsEntryId: ntm.odsEntryId!)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Front Cover pdf")
        tester().waitForView(withAccessibilityLabel: "File Size: 63 KB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(ntm.uploadTime!.formatted(date: .complete, time: .omitted))")

        let config = URLSessionConfiguration.default
//        DownloadManager.shared.sessionConfig = config
        
        stub(condition: isScheme("https") && pathEndsWith("api/publications/download")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("mockEpub.rtf", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/rtf"]
            )
        }
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "Download")
        tester().tapView(withAccessibilityLabel: "Download")
        
        XCTFail("Figure out how to test async")
//        let progressExpectation = expectation(for: repository.getNoticeToMariners(odsEntryId: ntm.odsEntryId!)?.downloadProgress == 1.0)
//
//        wait(for: [progressExpectation], timeout: 5)
//
//        expectation(forNotification: .DocumentPreview,
//                    object: nil) { notification in
//            let model: URL = try! XCTUnwrap(notification.object as? URL)
//            XCTAssertEqual(model.path, URL(string: ntm.savePath)!.path)
//            return true
//        }
//
//        tester().waitForView(withAccessibilityLabel: "Open")
//        tester().tapView(withAccessibilityLabel: "Open")
//        waitForExpectations(timeout: 10, handler: nil)
//        
//        XCTAssertTrue(repository.checkFileExists(odsEntryId: ntm.odsEntryId ?? -1))
//        tester().tapView(withAccessibilityLabel: "Delete")
//        XCTAssertFalse(repository.checkFileExists(odsEntryId: ntm.odsEntryId ?? -1))
    }

}
