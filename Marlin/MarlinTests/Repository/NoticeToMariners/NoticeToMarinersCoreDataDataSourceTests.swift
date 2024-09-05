//
//  NoticeToMarinersCoreDataDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation

import Combine
import CoreData

@testable import Marlin

final class NoticeToMarinersCoreDataDataSourceTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)

    override func setUp(completion: @escaping (Error?) -> Void) {
        Task.init {
            await TestHelpers.asyncGetKeyWindowVisible()
        }
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        UserDefaults.standard.setSort(DataSources.noticeToMariners.key, sort: DataSources.noticeToMariners.filterable!.defaultSort)
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.noticeToMariners)
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

    func testCount() {
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
            ntm.uploadTime = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
            ntm.lastModified = DataSources.noticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")

            newItem = ntm
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        let dataSource = NoticeToMarinersCoreDataDataSource()

        XCTAssertEqual(dataSource.getCount(filters: nil), 1)
    }
}
