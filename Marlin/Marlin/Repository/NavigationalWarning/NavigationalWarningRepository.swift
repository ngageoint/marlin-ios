//
//  NavigationalWarningRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 10/27/23.
//

import Foundation
import CoreData

protocol NavigationalWarningRepository {
    @discardableResult
    func getNavigationalWarning(msgYear: Int64, msgNumber: Int64, navArea: String?) -> NavigationalWarning?
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
}

class NavigationalWarningRepositoryManager: NavigationalWarningRepository, ObservableObject {
    private var repository: NavigationalWarningRepository
    init(repository: NavigationalWarningRepository) {
        self.repository = repository
    }
    
    func getNavigationalWarning(msgYear: Int64, msgNumber: Int64, navArea: String?) -> NavigationalWarning? {
        repository.getNavigationalWarning(msgYear: msgYear, msgNumber: msgNumber, navArea: navArea)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        repository.getCount(filters: filters)
    }
}

class NavigationalWarningCoreDataRepository: NavigationalWarningRepository, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getNavigationalWarning(msgYear: Int64, msgNumber: Int64, navArea: String?) -> NavigationalWarning? {
        if let navArea = navArea {
            return try? context.fetchFirst(
                NavigationalWarning.self,
                predicate: NSPredicate(
                    format: "msgYear = %d AND msgNumber = %d AND navArea = %@",
                    argumentArray: [msgYear, msgNumber, navArea]
                )
            )
        }
        return nil
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        guard let fetchRequest = NavigationalWarningFilterable()
            .fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        return (try? context.count(for: fetchRequest)) ?? 0
    }
}
