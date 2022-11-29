//
//  NoticeToMariners+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import Foundation
import SwiftUI

extension NoticeToMariners: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(NoticeToMarinersFullNoticeView(noticeNumber: self.noticeNumber))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(NoticeToMarinersSummaryView(noticeToMariners: self))
    }
}
