//
//  DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import Foundation
import UIKit

protocol DataSource {
    static var isMappable: Bool { get }
    static var dataSourceName: String { get }
    static var key: String { get }
    static var color: UIColor { get }
    static var imageName: String? { get }
    static var systemImageName: String? { get }
    var color: UIColor { get }
}
