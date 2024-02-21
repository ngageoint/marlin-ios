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

final class NoticeToMarinersSummaryViewTests: XCTestCase {

    func testFileSummaryView() {
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
        localDataSource.map[ntm.noticeNumber ?? -1] = ntm
        localDataSource.deleteFile(noticeNumber: ntm.noticeNumber ?? -1)
        let repository = NoticeToMarinersRepository(localDataSource: localDataSource, remoteDataSource: NoticeToMarinersStaticRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(noticeToMarinersRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summaryView = NoticeToMarinersFileSummaryView(noticeNumber: ntm.noticeNumber!)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Front Cover")
        tester().waitForView(withAccessibilityLabel: "File Size: 63 KB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(ntm.uploadTime!.formatted(date: .complete, time: .omitted))")
    }
    
    func testSummary() {
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
        localDataSource.map[ntm.noticeNumber ?? -1] = ntm
        localDataSource.deleteFile(noticeNumber: ntm.noticeNumber ?? -1)
        let repository = NoticeToMarinersRepository(localDataSource: localDataSource, remoteDataSource: NoticeToMarinersStaticRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(noticeToMarinersRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summaryView = NoticeToMarinersSummaryView(noticeToMariners: NoticeToMarinersListModel(noticeToMarinersModel: ntm))
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(MarlinRouter())

        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "202247")
        tester().waitForView(withAccessibilityLabel: "November 19 - November 25")
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkStaticRepository, bookmarkable: ntm)
    }
    
    func testReDownloadFullPublication() {
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
        localDataSource.map[ntm.noticeNumber ?? -1] = ntm
        localDataSource.deleteFile(noticeNumber: ntm.noticeNumber ?? -1)
        let repository = NoticeToMarinersRepository(localDataSource: localDataSource, remoteDataSource: NoticeToMarinersStaticRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(noticeToMarinersRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summaryView = NoticeToMarinersFileSummaryView(noticeNumber: ntm.noticeNumber!)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
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
        
        let progressExpectation = expectation(for: repository.getNoticeToMariners(noticeNumber: ntm.noticeNumber!)?.downloadProgress == 1.0)

        wait(for: [progressExpectation], timeout: 5)

        expectation(forNotification: .DocumentPreview,
                    object: nil) { notification in
            let model: URL = try! XCTUnwrap(notification.object as? URL)
            XCTAssertEqual(model.path, URL(string: ntm.savePath)!.path)
            return true
        }

        tester().waitForView(withAccessibilityLabel: "Open")
        tester().tapView(withAccessibilityLabel: "Open")
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(repository.checkFileExists(id: ntm.noticeNumber ?? -1))
        tester().tapView(withAccessibilityLabel: "Delete")
        XCTAssertFalse(repository.checkFileExists(id: ntm.noticeNumber ?? -1))
    }
    
    func testDownloadFullPublication() {
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
        localDataSource.map[ntm.noticeNumber ?? -1] = ntm
        localDataSource.deleteFile(noticeNumber: ntm.noticeNumber ?? -1)
        let repository = NoticeToMarinersRepository(localDataSource: localDataSource, remoteDataSource: NoticeToMarinersStaticRemoteDataSource())
        let bookmarkStaticRepository = BookmarkStaticRepository(noticeToMarinersRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let summaryView = NoticeToMarinersFileSummaryView(noticeNumber: ntm.noticeNumber!)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
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
        
        let progressExpectation = expectation(for: repository.getNoticeToMariners(noticeNumber: ntm.noticeNumber!)?.downloadProgress == 1.0)

        wait(for: [progressExpectation], timeout: 5)

        expectation(forNotification: .DocumentPreview,
                    object: nil) { notification in
            let model: URL = try! XCTUnwrap(notification.object as? URL)
            XCTAssertEqual(model.path, URL(string: ntm.savePath)!.path)
            return true
        }

        tester().waitForView(withAccessibilityLabel: "Open")
        tester().tapView(withAccessibilityLabel: "Open")
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(repository.checkFileExists(id: ntm.noticeNumber ?? -1))
        tester().tapView(withAccessibilityLabel: "Delete")
        XCTAssertFalse(repository.checkFileExists(id: ntm.noticeNumber ?? -1))
    }

}
