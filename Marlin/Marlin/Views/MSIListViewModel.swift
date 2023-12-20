//
//  MSIListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 10/3/22.
//

import Foundation
import CoreData
import Combine

struct MSISection<T: DataSource & BatchImportable>: Hashable {
    let id: Int
    let name: String
    let items: [T]
}

class MSIListViewModel<T: DataSource & BatchImportable>: 
    NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    @Published var sections: [MSISection<T>] = []
    @Published var lastUpdateDate: Date = Date()
    var sortDescriptors: [DataSourceSortParameter] = []
    var filters: [DataSourceFilterParameter] = []
    var fetchRequest = T.fetchRequest()
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var sectionKey: String?
    
    var cancellable = Set<AnyCancellable>()
    
    override init() {
        
        super.init()
        setupFetchedResultsController()
        
        UserDefaults.standard.filterPublisher(key: T.key)
            .removeDuplicates()
            .sink { _ in
                self.setupFetchedResultsController()
            }
            .store(in: &cancellable)
        
        UserDefaults.standard.sortPublisher(key: T.key)
            .removeDuplicates()
            .sink { _ in
                self.setupFetchedResultsController()
            }
            .store(in: &cancellable)
    }
    
    func setupFetchedResultsController() {
        let userSort = UserDefaults.standard.sort(T.key)
        if userSort.isEmpty {
            self.sortDescriptors = T.defaultSort
        } else {
            self.sortDescriptors = userSort
        }
        if !self.sortDescriptors.isEmpty && self.sortDescriptors[0].section {
            self.sectionKey = self.sortDescriptors[0].property.key
        } else {
            self.sectionKey = nil
        }
        
        self.filters = UserDefaults.standard.filter(T.definition)
        
        var predicates: [NSPredicate] = []
        
        for filter in filters {
            if let predicate = filter.toPredicate(
                dataSource: DataSourceDefinitions.filterableFromDefintion(T.definition)
            ) {
                predicates.append(predicate)
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        var sort: [NSSortDescriptor] = []
        for sortDescriptor in sortDescriptors {
            sort.append(sortDescriptor.toNSSortDescriptor())
        }
        
        fetchRequest.sortDescriptors = sort
        fetchRequest.predicate = predicate
        self.fetchedResultsController = 
        PersistenceController.current.fetchedResultsController(fetchRequest: fetchRequest,
                                                               sectionNameKeyPath: sectionKey,
                                                               cacheName: nil)
        self.fetchedResultsController?.delegate = self
        DispatchQueue.main.async { [self] in
            sections = []
            try? fetchedResultsController?.performFetch()
            self.update(for: 0)
            self.update(for: 1)
        }
    }
    
    func update(for sectionIndex: Int) {
        if let section = get(for: sectionIndex) {
            sections.insert(section, at: sectionIndex)
        }
    }
    
    func get(for sectionIndex: Int) -> MSISection<T>? {
        if sections.count - 1 > sectionIndex {
            return nil
        }
        if fetchedResultsController?.sectionNameKeyPath != nil,
           let sections = fetchedResultsController?.sections, sections.count > sectionIndex {
            let section = sections[sectionIndex]
            if let sectionItems = section.objects as? [T] {
                return MSISection(id: sectionIndex, name: section.name, items: sectionItems)
            }
        } else if sectionIndex == 0 {
            if let items = fetchedResultsController?.fetchedObjects as? [T] {
                return MSISection(id: 0, name: "All", items: items)
            }
        }
        return nil
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        lastUpdateDate = Date()
        // update the sections that were already loaded, or load the initial section if none loaded yet
        if sections.isEmpty {
            if let sectionLights = get(for: 0) {
                sections.insert(sectionLights, at: 0)
            }
        } else {
            for index in sections.indices {
                if let sectionLights = get(for: index) {
                    sections[index] = sectionLights
                }
            }
        }
    }
}
