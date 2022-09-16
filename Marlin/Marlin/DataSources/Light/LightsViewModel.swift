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
        super.init()
        self.fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        if let sectionLights = getLights(for: 0) {
            lights.insert(sectionLights, at: 0)
        }
    }
    
    func updateLights(for sectionIndex: Int) {
        if let sectionLights = getLights(for: sectionIndex) {
            lights.insert(sectionLights, at: sectionIndex)
        }
    }
    
    func getLights(for sectionIndex: Int) -> LightSection? {
        if lights.count - 1 > sectionIndex {
            return nil
        }
        if let sections = fetchedResultsController.sections, sections.count > sectionIndex {
            let section = sections[sectionIndex]
            if let sectionLights = section.objects as? [Light] {
                return LightSection(id: sectionIndex, name: section.name, lights: sectionLights)
            }
        }
        return nil
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // update the sections that were already loaded, or load the initial section if none loaded yet
        if lights.isEmpty {
            if let sectionLights = getLights(for: 0) {
                lights.insert(sectionLights, at: 0)
            }
        } else {
            for (index, light) in lights.enumerated() {
                if let sectionLights = getLights(for: index) {
                    lights[index] = sectionLights
                }
            }
        }
    }
}
