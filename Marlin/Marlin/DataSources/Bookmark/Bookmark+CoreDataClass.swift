//
//  Bookmark+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import Foundation
import CoreData

class Bookmark: NSManagedObject {
    
    func getDataSource() -> (any DataSource)? {
        switch(dataSource) {
        case Asam.key:
            print("asam")
        case Modu.key:
            print("modu")
        case Port.key:
            print("port")
        case NavigationalWarning.key:
            print("navigaitonal warning")
        case NoticeToMariners.key:
            print("notice to mariners")
        case DFRS.key:
            print("dfrs")
        case DifferentialGPSStation.key:
            print("dgps")
        case Light.key:
            print("light")
        case RadioBeacon.key:
            print("radio beacon")
        case ElectronicPublication.key:
            print("electronic publication")
        default:
            print("default")
        }
        return nil
    }
}
