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
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for dataSource in DataSourceDefinitions.allCases {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(dataSource.definition)
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
    
    override func tearDown(completion: @escaping (Error?) -> Void) {
        persistentStore.viewContext.performAndWait {
            if let nws = persistentStore.viewContext.fetchAll(NavigationalWarning.self) {
                for nw in nws {
                    persistentStore.viewContext.delete(nw)
                }
            }
            try? persistentStore.viewContext.save()
        }
        completion(nil)
    }
    
    func testLoading() {
        let nw = NavigationalWarning(context: persistentStore.viewContext)
        
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
        
        let repository = NavigationalWarningRepository(localDataSource: NavigationalWarningCoreDataDataSource(), remoteDataSource: NavigationalWarningRemoteDataSource())

        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(navigationalWarningRepository: repository))
        let summary = nw.summary
            .setShowMoreDetails(false)
            .environment(\.managedObjectContext, persistentStore.viewContext)
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
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: nw)

    }
}
