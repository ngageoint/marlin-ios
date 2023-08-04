//
//  NoticeToMariners+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import Foundation
import SwiftUI

extension NoticeToMariners: DataSourceViewBuilder {    
    var itemTitle: String {
        return "\(self.title ?? "") \(self.isFullPublication ? (self.fileExtension ?? "") : "")"
    }
    var detailView: AnyView {
        AnyView(NoticeToMarinersFullNoticeView(viewModel: NoticeToMarinersFullNoticeViewViewModel(noticeNumber: self.noticeNumber)))
    }
    
    var summary: some DataSourceSummaryView {
        NoticeToMarinersSummaryView(noticeToMariners: self)
    }
}
