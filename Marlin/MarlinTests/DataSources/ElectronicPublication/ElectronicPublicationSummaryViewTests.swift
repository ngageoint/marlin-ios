//
//  ElectronicPublicationSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import OHHTTPStubs
import Combine
import SwiftUI

@testable import Marlin

@available(iOS 16.0, *)
final class ElectronicPublicationSummaryViewTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        HTTPStubs.setEnabled(true)
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
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
        HTTPStubs.removeAllStubs()
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }
    
    func testNotDownloaded() {
        let epub = ElectronicPublication(context: persistentStore.viewContext)
        
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
        
        let summary = epub.summaryView(showMoreDetails: false)
        
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
        let epub = ElectronicPublication(context: persistentStore.viewContext)
        
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

        let summary = epub.summaryView(showMoreDetails: false)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: epub.sectionDisplayName)
        tester().waitForView(withAccessibilityLabel: "File Size: 2.4 MB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(epub.uploadTime?.formatted() ?? "")")
        
        let config = URLSessionConfiguration.default
        DownloadManager.shared.sessionConfig = config
        
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
        
        let e = XCTKeyPathExpectation(keyPath: \ElectronicPublication.downloadProgress, observedObject: epub, expectedValue: 1.0)
        wait(for: [e], timeout: 10)
                
        expectation(forNotification: .DocumentPreview,
                    object: nil) { notification in
            let model: URL = try! XCTUnwrap(notification.object as? URL)
            XCTAssertEqual(model.path, URL(string: epub.savePath)!.path)
            return true
        }
        
        tester().waitForView(withAccessibilityLabel: "Open")
        tester().tapView(withAccessibilityLabel: "Open")
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(epub.checkFileExists())
        tester().tapView(withAccessibilityLabel: "Delete")
        XCTAssertFalse(epub.checkFileExists())
    }
    
    func testDownloadError() {
        let epub = ElectronicPublication(context: persistentStore.viewContext)
        
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
        
        let summary = epub.summaryView(showMoreDetails: false)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: epub.sectionDisplayName)
        tester().waitForView(withAccessibilityLabel: "File Size: 2.4 MB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(epub.uploadTime?.formatted() ?? "")")
        
        let config = URLSessionConfiguration.default
        DownloadManager.shared.sessionConfig = config
        
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
        let epub = ElectronicPublication(context: persistentStore.viewContext)
        
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
        
        let summary = epub.summaryView(showMoreDetails: false)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: epub.sectionDisplayName)
        tester().waitForView(withAccessibilityLabel: "File Size: 2.4 MB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(epub.uploadTime?.formatted() ?? "")")
        
        let config = URLSessionConfiguration.default
        DownloadManager.shared.sessionConfig = config
        
        stub(condition: isScheme("https") && pathEndsWith("api/publications/download")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("mockEpub.rtf", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/rtf"]
            )
        }
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "Re-Download")
        tester().tapView(withAccessibilityLabel: "Re-Download")
        
        let e = XCTKeyPathExpectation(keyPath: \ElectronicPublication.downloadProgress, observedObject: epub, expectedValue: 1.0)
        wait(for: [e], timeout: 10)
        
        expectation(forNotification: .DocumentPreview,
                    object: nil) { notification in
            let model: URL = try! XCTUnwrap(notification.object as? URL)
            XCTAssertEqual(model.path, URL(string: epub.savePath)!.path)
            return true
        }
        
        tester().waitForView(withAccessibilityLabel: "Open")
        tester().tapView(withAccessibilityLabel: "Open")
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(epub.checkFileExists())
        tester().tapView(withAccessibilityLabel: "Delete")
        XCTAssertFalse(epub.checkFileExists())
    }
}
