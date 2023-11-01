//
//  AsamLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import CoreData
import Combine

protocol AsamLocalDataSource {
    @discardableResult
    func getAsam(reference: String?) -> AsamModel?
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel]
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func observeAsamListItems(filters: [DataSourceFilterParameter]?) -> AnyPublisher<CollectionDifference<AsamModel>, Never>
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
    
    func observeAsamListItems(filters: [DataSourceFilterParameter]?) -> AnyPublisher<CollectionDifference<AsamModel>, Never> {
        let request: NSFetchRequest<Asam> = AsamFilterable().fetchRequest(filters: filters, commonFilters: nil) as? NSFetchRequest<Asam> ?? Asam.fetchRequest()
        request.sortDescriptors = UserDefaults.standard.sort(Asam.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        return context.changesPublisher(for: request, transformer: { asam in
            AsamModel(asam: asam)
        })
        .receive(on: DispatchQueue.main)
        .catch { _ in Empty() }
        .eraseToAnyPublisher()
    }
}
