//
//  AsamLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import CoreData

protocol AsamLocalDataSource {
    @discardableResult
    func getAsam(reference: String?) -> AsamModel?
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel]
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
}

class AsamCoreDataDataSource: AsamLocalDataSource, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAsam(reference: String?) -> AsamModel? {
        if let reference = reference {
            if let asam = context.fetchFirst(Asam.self, key: "reference", value: reference) {
                return AsamModel(asam: asam)
            }
        }
        return nil
    }
    
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel] {
        return []
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        guard let fetchRequest = AsamFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        return (try? context.count(for: fetchRequest)) ?? 0
    }
}
