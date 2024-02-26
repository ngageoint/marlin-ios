//
//  NavigationalWarningDetailTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningDetailTests: XCTestCase {
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
    
    override func tearDown() {
    }
    
    func testLoading() {
        var newItem = NavigationalWarningModel()

        newItem.cancelMsgNumber = 1
        newItem.authority = "authority"
        newItem.cancelDate = Date(timeIntervalSince1970: 0)
        newItem.cancelMsgYear = 2020
        newItem.cancelNavArea = "P"
        newItem.issueDate = Date(timeIntervalSince1970: 0)
        newItem.msgNumber = 2
        newItem.msgYear = 2019
        newItem.navArea = "P"
        newItem.status = "status"
        newItem.subregion = "subregion"
        newItem.text = "text of the warning"

        let localDataSource = NavigationalWarningStaticLocalDataSource()
        localDataSource.list.append(newItem)
        let repository = NavigationalWarningRepository(localDataSource: localDataSource, remoteDataSource: NavigationalWarningRemoteDataSource())

        let bookmarkStaticRepository = BookmarkStaticRepository(navigationalWarningRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)
        let detailView = NavigationalWarningDetailView()
//        newItem.detailView.environment(\.managedObjectContext, persistentStore.viewContext)
            .environmentObject(bookmarkRepository)
        
        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "HYDROPAC 2/2019 (subregion)")
        tester().waitForView(withAccessibilityLabel: newItem.dateString)
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")

        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapView(withAccessibilityLabel: "dismiss popup")
        
        tester().waitForView(withAccessibilityLabel: "Authority")
        tester().waitForView(withAccessibilityLabel: newItem.authority)
        
        tester().waitForView(withAccessibilityLabel: "Cancel Date")
        tester().waitForView(withAccessibilityLabel: newItem.cancelDateString)
        
        tester().waitForView(withAccessibilityLabel: "Cancelled By")
        tester().waitForView(withAccessibilityLabel: "HYDROPAC \(newItem.cancelMsgNumber)/\(newItem.cancelMsgYear)")
        
        tester().waitForView(withAccessibilityLabel: "Text")
        let textView = viewTester().usingLabel("Text").view as! UITextView
        XCTAssertEqual(textView.text, newItem.text)
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkStaticRepository, bookmarkable: newItem)
    }
}
