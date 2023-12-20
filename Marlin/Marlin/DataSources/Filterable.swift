//
//  Filterable.swift
//  Marlin
//
//  Created by Daniel Barela on 10/12/23.
//

import Foundation
import CoreData

protocol Filterable {
    var id: String { get }
    var definition: any DataSourceDefinition { get }
    var properties: [DataSourceProperty] { get }
    var defaultFilter: [DataSourceFilterParameter] { get }
    var locatableClass: Locatable.Type? { get }
    func fetchRequest(
        filters: [DataSourceFilterParameter]?,
        commonFilters: [DataSourceFilterParameter]?
    ) -> NSFetchRequest<NSFetchRequestResult>?
}

extension Filterable {
    var id: String {
        definition.key
    }
    var locatableClass: Locatable.Type? {
        nil
    }
    
    func fetchRequest(
        filters: [DataSourceFilterParameter]?,
        commonFilters: [DataSourceFilterParameter]?
    ) -> NSFetchRequest<NSFetchRequestResult>? {
        // TODO: this should take a repostory
        let dataSourceNSManaged: NSManagedObject.Type? = 
            self as? NSManagedObject.Type ??
            DataSourceType.fromKey(definition.key)?.toDataSource() as? NSManagedObject.Type

        guard let dataSourceNSManaged = dataSourceNSManaged else {
            return nil
        }
        let fetchRequest = dataSourceNSManaged.fetchRequest()
        var predicates: [NSPredicate] = []
        
        if let commonFilters = commonFilters {
            for filter in commonFilters {
                if let predicate = filter.toPredicate(dataSource: self) {
                    predicates.append(predicate)
                }
            }
        }
        
        if let filters = filters {
            for filter in filters {
                if let predicate = filter.toPredicate(dataSource: self) {
                    predicates.append(predicate)
                }
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}
