//
//  LightsViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/22.
//

import Foundation
import CoreData

struct LightListItem : Decodable, Hashable{
    let id : Int
    let email : String
    let firstName : String
    let lastName : String
    let avatar : URL
}

struct LightSection: Hashable {
    let id: Int
    let name: String
    let lights: [Light]
}

class LightsViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    //MARK: - Properties
    @Published var lights : [LightSection] = []    
    var fetchRequest = Light.fetchRequest()
    var fetchedResultsController: NSFetchedResultsController<Light>
    
    override init() {
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Light.sectionHeader, ascending: true), NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "characteristicNumber = 1")
        self.fetchedResultsController = NSFetchedResultsController<Light>(fetchRequest: fetchRequest,
                                                                   managedObjectContext: PersistenceController.shared.container.viewContext,
                                                                   sectionNameKeyPath: "sectionHeader",
                                                                   cacheName: nil)
        try? fetchedResultsController.performFetch()
        
        super.init()
        getLights(for: 0)
    }
    
    func getLights(for sectionIndex: Int){
        if lights.count - 1 > sectionIndex {
            return
        }
        if let section = fetchedResultsController.sections?[sectionIndex], let sectionLights = section.objects as? [Light] {
            lights.append(LightSection(id: sectionIndex, name: section.name, lights: sectionLights))
        }
    }
}
