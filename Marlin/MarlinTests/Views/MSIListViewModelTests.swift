//
//  MSIListViewModelTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/31/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class MSIListViewModelTests: XCTestCase {

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

        UserDefaults.standard.setFilter(Asam.key, filter: [])
        UserDefaults.standard.setSort(Asam.key, sort: Asam.defaultSort)

        persistentStore.viewContext.performAndWait {
            if let asams = persistentStore.viewContext.fetchAll(Asam.self) {
                for asam in asams {
                    persistentStore.viewContext.delete(asam)
                }
            }
        }
        
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
                    if let count = try? self.persistentStore.countOfObjects(Asam.self) {
                        return count == 0
                    }
                    return false
                }), object: self.persistentStore.viewContext)
                self.wait(for: [e5], timeout: 10)
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
        
    }
    override func tearDown(completion: @escaping (Error?) -> Void) {
        persistentStore.viewContext.performAndWait {
            if let asams = persistentStore.viewContext.fetchAll(Asam.self) {
                for asam in asams {
                    persistentStore.viewContext.delete(asam)
                }
            }
        }
        completion(nil)
    }

    func testOneSectionList() throws {
        UserDefaults.standard.setSort(Asam.key, sort: [])
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        let listViewModel = MSIListViewModel<Asam>()
        
        let sectionExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            return observedObject.sections.count == 1
        }), object: listViewModel)
        
        wait(for: [sectionExpectation], timeout: 10)
        
        let itemExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            let section = observedObject.get(for: 0)!
            return section.items.count == 2
        }), object: listViewModel)
        
        wait(for: [itemExpectation], timeout: 10)
        for cancellable in listViewModel.cancellable {
            cancellable.cancel()
        }
    }
    
    func testZeroItemList() throws {
        let listViewModel = MSIListViewModel<Asam>()
        
        let sectionExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            return observedObject.sections.count == 1
        }), object: listViewModel)
        
        wait(for: [sectionExpectation], timeout: 10)
        
        let section = listViewModel.get(for: 0)!
        XCTAssertEqual(section.items.count, 0)
        
        XCTAssertNil(listViewModel.get(for: 1))
        for cancellable in listViewModel.cancellable {
            cancellable.cancel()
        }
    }
    
    func testAddItemsList() throws {
        let listViewModel = MSIListViewModel<Asam>()
        
        let sectionExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            return observedObject.sections.count == 1
        }), object: listViewModel)
        
        wait(for: [sectionExpectation], timeout: 10)
        
        let section = listViewModel.get(for: 0)!
        XCTAssertEqual(section.items.count, 0)
        
        XCTAssertNil(listViewModel.get(for: 1))
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        let itemExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            let section = observedObject.get(for: 0)!
            return section.items.count == 2
        }), object: listViewModel)
        
        wait(for: [itemExpectation], timeout: 10)
        for cancellable in listViewModel.cancellable {
            cancellable.cancel()
        }
    }
    
    func testAddItemsListWithSectionKey() throws {
        
        UserDefaults.standard.setSort(Asam.key, sort: [DataSourceSortParameter(property:DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date), ascending: false, section: true)])
        
        let listViewModel = MSIListViewModel<Asam>()
        
        let sectionExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            return observedObject.sections.count == 1
        }), object: listViewModel)
        
        wait(for: [sectionExpectation], timeout: 10)
        
        let section = listViewModel.get(for: 0)!
        XCTAssertEqual(section.items.count, 0)
        
        XCTAssertNil(listViewModel.get(for: 1))
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        let itemExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            let section0 = observedObject.get(for: 0)
            let section1 = observedObject.get(for: 1)
            return section0?.items.count == 1 && section1?.items.count == 1
        }), object: listViewModel)
        
        wait(for: [itemExpectation], timeout: 10)
        for cancellable in listViewModel.cancellable {
            cancellable.cancel()
        }
    }
    
    func testFilteredList() throws {
        
        UserDefaults.standard.setSort(Asam.key, sort: Asam.defaultSort)
        UserDefaults.standard.setFilter(Asam.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last30Days)])
        
        let listViewModel = MSIListViewModel<Asam>()
        
        let sectionExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            return observedObject.sections.count == 1
        }), object: listViewModel)
        
        wait(for: [sectionExpectation], timeout: 10)
        
        let section = listViewModel.get(for: 0)!
        XCTAssertEqual(section.items.count, 0)
        
        XCTAssertNil(listViewModel.get(for: 1))
        
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date()
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 2.0
            asam2.latitude = 2.0
            asam2.date = Date(timeIntervalSince1970: 100000)
            asam2.navArea = "XI"
            asam2.reference = "2022-102"
            asam2.subreg = "71"
            asam2.position = "2°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding2"
            asam2.victim = "Boat2"
            
            try? persistentStore.viewContext.save()
        }
        
        let itemExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, dictionary in
            guard let observedObject = observedObject as? MSIListViewModel<Asam> else {
                return false
            }
            let section0 = observedObject.get(for: 0)
            let section1 = observedObject.get(for: 1)
            return section0?.items.count == 1 && section1 == nil
        }), object: listViewModel)
        
        wait(for: [itemExpectation], timeout: 10)
        for cancellable in listViewModel.cancellable {
            cancellable.cancel()
        }
    }

}
