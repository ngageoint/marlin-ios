//
//  MSIListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 10/3/22.
//

import Foundation
import CoreData
import Combine

struct MSISection<T: DataSource>: Hashable {
    let id: Int
    let name: String
    let items: [T]
}

class MSIListViewModel<T: DataSource>: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    @Published var sections : [MSISection<T>] = []
    var sortDescriptors: [DataSourceSortParameter] = []
    var filters: [DataSourceFilterParameter] = []
    var fetchRequest = T.fetchRequest()
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
    var sectionKey: String? = nil
    
    var cancellable = Set<AnyCancellable>()
    
    init(filterPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>, sortPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>) {
        
        super.init()
        setupFetchedResultsController()
        
        filterPublisher
            .removeDuplicates()
            .sink { output in
                self.setupFetchedResultsController()
            }
            .store(in: &cancellable)
        
        sortPublisher
            .removeDuplicates()
            .sink { output in
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
        if self.sortDescriptors[0].section {
            self.sectionKey = self.sortDescriptors[0].property.key
        } else {
            self.sectionKey = nil
        }
        
        self.filters = UserDefaults.standard.filter(T.self)
        
        var predicates: [NSPredicate] = []
        
        for filter in filters {
            if let predicate = filter.toPredicate() {
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
        self.fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest,
                                                                                         managedObjectContext: PersistenceController.shared.container.viewContext,
                                                                                         sectionNameKeyPath: sectionKey,
                                                                                         cacheName: nil)
        self.fetchedResultsController?.delegate = self
        sections = []
        try? fetchedResultsController?.performFetch()
        self.update(for: 0)
        self.update(for: 1)
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
        if fetchedResultsController?.sectionNameKeyPath != nil, let sections = fetchedResultsController?.sections, sections.count > sectionIndex {
            let section = sections[sectionIndex]
            if let sectionItems = section.objects as? [T] {
                return MSISection(id: sectionIndex, name: section.name, items: sectionItems)
            }
        } else if sectionIndex == 0 {
            if let items = fetchedResultsController?.fetchedObjects as? [T] {
                return MSISection(id: 0, name: "", items: items)
            }
        }
        return nil
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // update the sections that were already loaded, or load the initial section if none loaded yet
        if sections.isEmpty {
            if let sectionLights = get(for: 0) {
                sections.insert(sectionLights, at: 0)
            }
        } else {
            for (index, section) in sections.enumerated() {
                if let sectionLights = get(for: index) {
                    sections[index] = sectionLights
                }
            }
        }
    }
}
