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
        var newItem: NoticeToMariners?
        persistentStore.viewContext.performAndWait {
            let ntm = NoticeToMariners(context: persistentStore.viewContext)
            
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
            ntm.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
            ntm.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")
            
            newItem = ntm
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summaryView = NoticeToMarinersFileSummaryView(noticeToMariners: newItem).environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Front Cover")
        tester().waitForView(withAccessibilityLabel: "File Size: 63 KB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(newItem.uploadTime!.formatted(date: .complete, time: .omitted))")
    }
    
    func testSummary() {
        var newItem: NoticeToMariners?
        persistentStore.viewContext.performAndWait {
            let ntm = NoticeToMariners(context: persistentStore.viewContext)
            
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
            ntm.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
            ntm.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")
            
            newItem = ntm
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
        
        let summaryView = NoticeToMarinersSummaryView(noticeToMariners: newItem).environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "202247")
        tester().waitForView(withAccessibilityLabel: "November 19 - November 25")
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: newItem)
    }
    
    func testReDownloadFullPublication() {
        var newItem: NoticeToMariners?
        persistentStore.viewContext.performAndWait {
            let ntm = NoticeToMariners(context: persistentStore.viewContext)
            
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
            ntm.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
            ntm.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")
            ntm.isDownloaded = false
            ntm.isDownloading = true
            
            newItem = ntm
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let summaryView = NoticeToMarinersFileSummaryView(noticeToMariners: newItem).environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Front Cover pdf")
        tester().waitForView(withAccessibilityLabel: "File Size: 63 KB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(newItem.uploadTime!.formatted(date: .complete, time: .omitted))")
        
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
        tester().waitForView(withAccessibilityLabel: "Cancel")
        tester().tapView(withAccessibilityLabel: "Cancel")
        tester().waitForView(withAccessibilityLabel: "Download")
        tester().tapView(withAccessibilityLabel: "Download")
        
        let e = XCTKeyPathExpectation(keyPath: \NoticeToMariners.downloadProgress, observedObject: newItem, expectedValue: 1.0)
        wait(for: [e], timeout: 10)
        
        expectation(forNotification: .DocumentPreview,
                    object: nil) { notification in
            let model: URL = try! XCTUnwrap(notification.object as? URL)
            XCTAssertEqual(model.path, URL(string: newItem.savePath)!.path)
            return true
        }
        
        tester().waitForView(withAccessibilityLabel: "Open")
        tester().tapView(withAccessibilityLabel: "Open")
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(newItem.checkFileExists())
        tester().tapView(withAccessibilityLabel: "Delete")
        XCTAssertFalse(newItem.checkFileExists())
    }
    
    func testDownloadFullPublication() {
        var newItem: NoticeToMariners?
        persistentStore.viewContext.performAndWait {
            let ntm = NoticeToMariners(context: persistentStore.viewContext)
            
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
            ntm.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
            ntm.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")
            ntm.isDownloaded = false
            ntm.isDownloading = false
            
            newItem = ntm
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))

        let summaryView = NoticeToMarinersFileSummaryView(noticeToMariners: newItem).environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: summaryView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Front Cover pdf")
        tester().waitForView(withAccessibilityLabel: "File Size: 63 KB")
        tester().waitForView(withAccessibilityLabel: "Upload Time: \(newItem.uploadTime!.formatted(date: .complete, time: .omitted))")
        
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
        
        let e = XCTKeyPathExpectation(keyPath: \NoticeToMariners.downloadProgress, observedObject: newItem, expectedValue: 1.0)
        wait(for: [e], timeout: 10)
        
        expectation(forNotification: .DocumentPreview,
                    object: nil) { notification in
            let model: URL = try! XCTUnwrap(notification.object as? URL)
            XCTAssertEqual(model.path, URL(string: newItem.savePath)!.path)
            return true
        }
        
        tester().waitForView(withAccessibilityLabel: "Open")
        tester().tapView(withAccessibilityLabel: "Open")
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertTrue(newItem.checkFileExists())
        tester().tapView(withAccessibilityLabel: "Delete")
        XCTAssertFalse(newItem.checkFileExists())
    }

}
