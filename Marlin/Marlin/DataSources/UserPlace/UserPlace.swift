//
//  UserPlace.swift
//  Marlin
//
//  Created by Daniel Barela on 2/26/24.
//

import Foundation
import CoreData

class UserPlace: NSManagedObject {

    func populateFromModel(userPlaceModel: UserPlaceModel) {
        self.date = userPlaceModel.date ?? Date()
        self.name = userPlaceModel.name
        self.latitude = userPlaceModel.latitude ?? -180.0
        self.longitude = userPlaceModel.longitude ?? -180.0
        self.maxLatitude = userPlaceModel.maxLatitude ?? -180.0
        self.maxLongitude = userPlaceModel.maxLongitude ?? -180.0
        self.minLatitude = userPlaceModel.minLatitude ?? -180.0
        self.minLongitude = userPlaceModel.minLongitude ?? -180.0
        self.json = userPlaceModel.json
    }
}
