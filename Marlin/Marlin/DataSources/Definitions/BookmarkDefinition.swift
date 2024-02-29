//
//  BookmarkDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    
    class BookmarkDefinition: DataSourceDefinition {
        var filterable: Filterable?
        var mappable: Bool = false
        var color: UIColor = UIColor(argbValue: 0xFFFF9500)
        var imageName: String?
        var systemImageName: String? = "bookmark.fill"
        var key: String = "bookmark"
        var metricsKey: String = "bookmark"
        var name: String = NSLocalizedString("Bookmarks", comment: "Bookmarks data source display name")
        var fullName: String = NSLocalizedString("Bookmarks", comment: "Bookmarks data source full display name")
        @AppStorage("bookmarkOrder") var order: Int = 0
        
        static let definition = BookmarkDefinition()
        private init() { }
    }
}
