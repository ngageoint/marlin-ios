//
//  PublicationDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    
    class PublicationDefinition: DataSourceDefinition {
        var filterable: Filterable? = PublicationFilterable()
        var mappable: Bool = false
        var color: UIColor = UIColor(argbValue: 0xFF30B0C7)
        var imageName: String?
        var systemImageName: String? = "doc.text.fill"
        var key: String = "epub"
        var metricsKey: String = "epubs"
        var name: String = NSLocalizedString("EPUB", comment: "Electronic Publication data source display name")
        var fullName: String =
        NSLocalizedString("Electronic Publications", comment: "Electronic Publication data source full display name")
        @AppStorage("epubOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every day
            return UserDefaults.standard.dataSourceEnabled(DataSources.epub)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 1)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.epub)
        }
        var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return dateFormatter
        }
        var backgroundDownloadIdentifier: String { "\(key)Download" }
        
        static let definition = PublicationDefinition()
        private init() { }
    }
}
