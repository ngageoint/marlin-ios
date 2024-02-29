//
//  NoticeToMarinersDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import UIKit
import SwiftUI

extension DataSources {
    
    class NoticeToMarinersDefinition: DataSourceDefinition {
        var filterable: Filterable? = NoticeToMarinersFilterable()
        var mappable: Bool = false
        var color: UIColor = UIColor.red
        var imageName: String?
        var systemImageName: String? = "speaker.badge.exclamationmark.fill"
        var key: String = "ntm"
        var metricsKey: String = "ntms"
        var name: String = "NTM"
        var fullName: String = "Notice To Mariners"
        var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return dateFormatter
        }
        @AppStorage("ntmOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every day
            return UserDefaults.standard.dataSourceEnabled(DataSources.noticeToMariners)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.noticeToMariners)
        }
        
        static let definition = NoticeToMarinersDefinition()
        private init() { }
    }
}
