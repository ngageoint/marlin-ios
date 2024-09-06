//
//  PublicationSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import OHHTTPStubs
import Combine
import SwiftUI

@testable import Marlin

final class PublicationSummaryViewTests: XCTestCase {
    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }
    
    func testNotDownloaded() {
        var epub = PublicationModel()

        epub.pubTypeId = 9
        epub.pubDownloadId = 3
        epub.fullPubFlag = false
        epub.pubDownloadOrder = 1
        epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
        epub.pubsecId = 129
        epub.odsEntryId = 22266
        epub.sectionOrder = 1
        epub.sectionName = "UpdatedPub110bk"
        epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
        epub.sectionLastModified = Date(timeIntervalSince1970: 0)
        epub.contentId = 16694312
        epub.internalPath = "NIMA_LOL/Pub110"
        epub.filenameBase = "UpdatedPub110bk"
        epub.fileExtension = "pdf"
        epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
        epub.fileSize = 2389496
        epub.uploadTime = Date(timeIntervalSince1970: 0)
        epub.fullFilename = "UpdatedPub110bk.pdf"
        epub.pubsecLastModified = Date(timeIntervalSince1970: 0)

        let localDataSource = PublicationStaticLocalDataSource()
        let remoteDataSource = PublicationRemoteDataSource()
        InjectedValues[\.publicationLocalDataSource] = localDataSource
        InjectedValues[\.publicationRemoteDataSource] = remoteDataSource
        localDataSource.map[epub.s3Key ?? ""] = epub
        

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = PublicationSummaryView(s3Key: epub.s3Key ?? "")
            .setShowMoreDetails(false)
            .environmentObject(MarlinRouter())

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: epub.sectionDisplayName)
        tester().waitForView(withAccessibilityLabel: "File Size: 2.4 MB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(epub.uploadTime?.formatted() ?? "")")
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "Download")
    }
    
    func testDownload() {
        var epub = PublicationModel()

        epub.pubTypeId = 9
        epub.pubDownloadId = 3
        epub.fullPubFlag = false
        epub.pubDownloadOrder = 1
        epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
        epub.pubsecId = 129
        epub.odsEntryId = 22266
        epub.sectionOrder = 1
        epub.sectionName = "UpdatedPub110bk"
        epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
        epub.sectionLastModified = Date(timeIntervalSince1970: 0)
        epub.contentId = 16694312
        epub.internalPath = "NIMA_LOL/Pub110"
        epub.filenameBase = "UpdatedPub110bk"
        epub.fileExtension = "pdf"
        epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
        epub.fileSize = 2389496
        epub.uploadTime = Date(timeIntervalSince1970: 0)
        epub.fullFilename = "UpdatedPub110bk.pdf"
        epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
        epub.isDownloaded = false

        let localDataSource = PublicationStaticLocalDataSource()
        let remoteDataSource = PublicationStaticRemoteDataSource()
        InjectedValues[\.publicationLocalDataSource] = localDataSource
        InjectedValues[\.publicationRemoteDataSource] = remoteDataSource
        localDataSource.map[epub.s3Key ?? ""] = epub
        localDataSource.deleteFile(s3Key: epub.s3Key ?? "")
        
        @Injected(\.publicationRepository)
        var repository: PublicationRepository

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = PublicationSummaryView(s3Key: epub.s3Key ?? "")
            .setShowMoreDetails(false)
            .environmentObject(MarlinRouter())

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: epub.sectionDisplayName)
        tester().waitForView(withAccessibilityLabel: "File Size: 2.4 MB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(epub.uploadTime?.formatted() ?? "")")

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
        
        let progressExpectation = expectation(for: repository.getPublication(s3Key: epub.s3Key)?.downloadProgress == 1.0)

        wait(for: [progressExpectation], timeout: 5)
        let preview = expectation(forNotification: .DocumentPreview,
                    object: nil) { notification in
            let model: URL = try! XCTUnwrap(notification.object as? URL)
            XCTAssertEqual(model.path, URL(string: epub.savePath)!.path)
            return true
        }
        
        tester().waitForView(withAccessibilityLabel: "Open")
        tester().tapView(withAccessibilityLabel: "Open")
        wait(for: [preview], timeout: 5)

        XCTAssertTrue(repository.checkFileExists(id: epub.s3Key ?? ""))
        tester().tapView(withAccessibilityLabel: "Delete")
        XCTAssertFalse(repository.checkFileExists(id: epub.s3Key ?? ""))
    }
    
    func testDownloadError() {
        var epub = PublicationModel()

        epub.pubTypeId = 9
        epub.pubDownloadId = 3
        epub.fullPubFlag = false
        epub.pubDownloadOrder = 1
        epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
        epub.pubsecId = 129
        epub.odsEntryId = 22266
        epub.sectionOrder = 1
        epub.sectionName = "UpdatedPub110bk"
        epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
        epub.sectionLastModified = Date(timeIntervalSince1970: 0)
        epub.contentId = 16694312
        epub.internalPath = "NIMA_LOL/Pub110"
        epub.filenameBase = "UpdatedPub110bk"
        epub.fileExtension = "pdf"
        epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
        epub.fileSize = 2389496
        epub.uploadTime = Date(timeIntervalSince1970: 0)
        epub.fullFilename = "UpdatedPub110bk.pdf"
        epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
        epub.isDownloaded = false
        
        let localDataSource = PublicationStaticLocalDataSource()
        let remoteDataSource = PublicationStaticRemoteDataSource()
        InjectedValues[\.publicationLocalDataSource] = localDataSource
        InjectedValues[\.publicationRemoteDataSource] = remoteDataSource
        localDataSource.map[epub.s3Key ?? ""] = epub
        localDataSource.deleteFile(s3Key: epub.s3Key ?? "")

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = PublicationSummaryView(s3Key: epub.s3Key ?? "")
            .setShowMoreDetails(false)
            .environmentObject(MarlinRouter())

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: epub.sectionDisplayName)
        tester().waitForView(withAccessibilityLabel: "File Size: 2.4 MB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(epub.uploadTime?.formatted() ?? "")")

        stub(condition: isScheme("https") && pathEndsWith("api/publications/download")) { request in
            let response = HTTPStubsResponse()
            response.statusCode = 403
            return response
        }
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "Download")
        tester().tapView(withAccessibilityLabel: "Download")
        tester().waitForView(withAccessibilityLabel: "Error downloading (403)")
    }
    
    func testReDownload() {

        var epub = PublicationModel()

        epub.pubTypeId = 9
        epub.pubDownloadId = 3
        epub.fullPubFlag = false
        epub.pubDownloadOrder = 1
        epub.pubDownloadDisplayName = "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies"
        epub.pubsecId = 129
        epub.odsEntryId = 22266
        epub.sectionOrder = 1
        epub.sectionName = "UpdatedPub110bk"
        epub.sectionDisplayName = "Pub 110 - Updated to NTM 44/22"
        epub.sectionLastModified = Date(timeIntervalSince1970: 0)
        epub.contentId = 16694312
        epub.internalPath = "NIMA_LOL/Pub110"
        epub.filenameBase = "UpdatedPub110bk"
        epub.fileExtension = "pdf"
        epub.s3Key = "16694312/SFH00000/NIMA_LOL/Pub110/UpdatedPub110bk.pdf"
        epub.fileSize = 2389496
        epub.uploadTime = Date(timeIntervalSince1970: 0)
        epub.fullFilename = "UpdatedPub110bk.pdf"
        epub.pubsecLastModified = Date(timeIntervalSince1970: 0)
        epub.isDownloaded = false
        epub.isDownloading = true

        let localDataSource = PublicationStaticLocalDataSource()
        let remoteDataSource = PublicationStaticRemoteDataSource()
        InjectedValues[\.publicationLocalDataSource] = localDataSource
        InjectedValues[\.publicationRemoteDataSource] = remoteDataSource
        localDataSource.map[epub.s3Key ?? ""] = epub
        localDataSource.deleteFile(s3Key: epub.s3Key ?? "")
        let repository = PublicationRepository()

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = PublicationSummaryView(s3Key: epub.s3Key ?? "")
            .setShowMoreDetails(false)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: epub.sectionDisplayName)
        tester().waitForView(withAccessibilityLabel: "File Size: 2.4 MB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(epub.uploadTime?.formatted() ?? "")")

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
        
        let progressExpectation = expectation(for: repository.getPublication(s3Key: epub.s3Key)?.downloadProgress == 1.0)

        wait(for: [progressExpectation], timeout: 5)
        
        expectation(forNotification: .DocumentPreview,
                    object: nil) { notification in
            let model: URL = try! XCTUnwrap(notification.object as? URL)
            XCTAssertEqual(model.path, URL(string: epub.savePath)!.path)
            return true
        }
        
        tester().waitForView(withAccessibilityLabel: "Open")
        tester().tapView(withAccessibilityLabel: "Open")
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(repository.checkFileExists(id: epub.s3Key ?? ""))
        tester().tapView(withAccessibilityLabel: "Delete")
        XCTAssertFalse(repository.checkFileExists(id: epub.s3Key ?? ""))

        BookmarkHelper().verifyBookmarkButton(bookmarkable: epub)
    }
}
