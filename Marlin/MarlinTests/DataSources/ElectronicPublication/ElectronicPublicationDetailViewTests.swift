//
//  ElectronicPublicationDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/23/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class ElectronicPublicationDetailViewTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
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
    }
    
    override func tearDown() {
    }
    func testDetailView() {
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
        
        let detailView = epub.detailView
        
        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: epub.pubDownloadDisplayName)
        tester().waitForView(withAccessibilityLabel: PublicationTypeEnum(rawValue: Int(epub.pubTypeId))?.description)
        tester().waitForView(withAccessibilityLabel: "\(ElectronicPublication.dateFormatter.string(from: epub.uploadTime!))")
    }
}
