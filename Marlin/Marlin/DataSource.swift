//
//  DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import Foundation
import UIKit
import SwiftUI
import MapKit
import CoreData

struct Throwable<T: Decodable>: Decodable {
    let result: Result<T, Error>
    
    init(from decoder: Decoder) throws {
        result = Result(catching: { try T(from: decoder) })
    }
}

protocol BatchImportable: NSManagedObject {
    static func batchImport(value: Decodable?) async throws
    static func dataRequest() -> [MSIRouter]
    static var key: String { get }
    static var seedDataFiles: [String]? { get }
    static var decodableRoot: Decodable.Type { get }
}

protocol DataSource: BatchImportable {
    static var isMappable: Bool { get }
    static var dataSourceName: String { get }
    static var fullDataSourceName: String { get }
    static var key: String { get }
    static var color: UIColor { get }
    static var imageName: String? { get }
    static var systemImageName: String? { get }
    var color: UIColor { get }
    static var image: UIImage? { get }
    static var imageScale: CGFloat { get }
    var coordinate: CLLocationCoordinate2D? { get }
    func view(on: MKMapView) -> MKAnnotationView?
}

extension DataSource {
    
    static var image: UIImage? {
        if let imageName = imageName {
            return UIImage(named: imageName)
        } else if let systemImageName = systemImageName {
            return UIImage(systemName: systemImageName)
        }
        return nil
    }
    
    func view(on: MKMapView) -> MKAnnotationView? {
        return nil
    }
    
    var coordinate: CLLocationCoordinate2D? {
        return nil
    }
}

protocol DataSourceViewBuilder: DataSource {
    var detailView: AnyView { get }
    func summaryView(showMoreDetails: Bool, showSectionHeader: Bool) -> AnyView
}

