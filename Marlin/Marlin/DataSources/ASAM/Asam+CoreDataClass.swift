//
//  Asam+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 6/2/22.
//
//

import Foundation
import CoreData
import MapKit
import CoreData

protocol AsamRepostory {
    associatedtype A: AsamModel
    @discardableResult
    func getAsam(reference: String?) -> A?
}

class MainAsamRepository: AsamRepostory {
    typealias A = Asam
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAsam(reference: String?) -> A? {
        if let reference = reference {
            return context.fetchFirst(Asam.self, key: "reference", value: reference)
        }
        return nil
    }
}

class RouteAsamRepository: AsamRepostory {
    typealias A = AsamPlain
    private var context: NSManagedObjectContext
    private var routeId: String
    
    required init(context: NSManagedObjectContext, routeId: String) {
        self.context = context
        self.routeId = routeId
    }
    
    func getAsam(reference: String?) -> A? {
//        if let reference = reference {
//            return context.fetchFirst(Asam.self, key: "reference", value: reference)
//        }
        return nil
    }
}

class AsamViewModel: ObservableObject, Identifiable {
    @Published var modelChange: Date = Date()
    @Published var asam: (any AsamModel)?
    @Published var predicate: NSPredicate?
    
    var repository: any AsamRepostory
    init(repository: any AsamRepostory) {
        self.repository = repository
    }
    
    @discardableResult
    func getAsam(reference: String) -> (any AsamModel)? {
        predicate = NSPredicate(format: "reference == %@", reference)
        asam = repository.getAsam(reference: reference)
        return asam
    }
}

protocol AsamModel: Equatable {
    var asamDescription: String? { get set }
    var date: Date? { get set }
    var hostility: String? { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var mgrs10km: String? { get set }
    var navArea: String? { get set }
    var position: String? { get set }
    var reference: String? { get set }
    var subreg: String? { get set }
    var victim: String? { get set }
    func isEqualTo(_ other: any AsamModel) -> Bool
}

extension AsamModel where Self: Equatable  {
    func isEqualTo(_ other: any AsamModel) -> Bool {
        guard let otherShape = other as? Self else { return false }
        return self == otherShape
    }
}

extension AsamModel {
    var dateString: String? {
        if let date = date {
            return Asam.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var itemTitle: String {
        return "\(self.hostility ?? "")\(self.hostility != nil && self.victim != nil ? ": " : "")\(self.victim ?? "")"
    }
}

extension AsamPlain: Equatable {
    static func ==(lhs: AsamPlain, rhs: AsamPlain) -> Bool {
        if let reference = lhs.reference {
            return reference == rhs.reference
        }
        return false
    }
}

class AsamPlain: AsamModel {
    var asamDescription: String?
    
    var date: Date?
    
    var hostility: String?
    
    var latitude: Double = kCLLocationCoordinate2DInvalid.latitude
    
    var longitude: Double = kCLLocationCoordinate2DInvalid.longitude
    
    var mgrs10km: String?
    
    var navArea: String?
    
    var position: String?
    
    var reference: String?
    
    var subreg: String?
    
    var victim: String?
    
    func isEqualTo(_ other: any AsamModel) -> Bool {
        guard let otherShape = other as? Self else { return false }
        return self == otherShape
    }
}

class Asam: NSManagedObject, EnlargableAnnotation, AsamModel {
    var clusteringIdentifierWhenShrunk: String? = "msi"
    
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var clusteringIdentifier: String? = "msi"
    
    var color: UIColor {
        return Asam.color
    }
    
    var annotationView: MKAnnotationView?
    
    var dateString: String? {
        if let date = date {
            return Asam.dateFormatter.string(from: date)
        }
        return nil
    }
    
    override var description: String {
        return "ASAM\n\n" +
        "Reference: \(reference ?? "")\n" +
        "Date: \(dateString ?? "")\n" +
        "Latitude: \(latitude)\n" +
        "Longitude: \(longitude)\n" +
        "Navigation Area: \(navArea ?? "")\n" +
        "Subregion: \(subreg ?? "")\n" +
        "Description: \(asamDescription ?? "")\n" +
        "Hostility: \(hostility ?? "")\n" +
        "Victim: \(victim ?? "")\n"
    }
}
